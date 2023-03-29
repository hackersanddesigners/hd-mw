{ pkgs, config, ... }:

let
  db_config = builtins.fromTOML(builtins.readFile ./.env.toml);
in

{
  packages = [ pkgs.git ];

  languages.php = {
    enable = true;
    version = "8.1";
    ini = ''
memory_limit = 256M
'';
    extensions = [
      "calendar"
      "curl"
      "openssl"
      "mbstring"
      "fileinfo"
      "intl"
      "apcu"
    ];

    fpm.pools.web = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 100;
        "pm.start_servers" = 50;
        "pm.min_spare_servers" = 25;
        "pm.max_spare_servers" = 100;
      };
    };
  };

  services.caddy.enable = true;
  services.caddy.virtualHosts."http://localhost:8000" = {
    extraConfig = ''
      root * w
      php_fastcgi unix/${config.languages.php.fpm.pools.web.socket}
      file_server
    '';
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  services.mysql.initialDatabases = [
    { name = db_config.name; schema = ./${db_config.schema}; }
  ];
  services.mysql.ensureUsers = [
    {
      name = db_config.user;
      password = db_config.pw;
      ensurePermissions = {
        "${db_config.name}.*" = "SELECT, UPDATE, INSERT, DELETE, ALTER, CREATE, INDEX, DROP, LOCK TABLES, USAGE";
      };
    }
  ];

}
