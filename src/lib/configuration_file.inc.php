<?php
  require_once( DIR_LIB . '/factory.inc.php' );
  class ConfigurationFile {
    private static $mConfigData;
    public static function parse() {
      if( empty( self::$mConfigData ) ) {
        $params = Factory::getParameters();
        $file = isset( $params[ 'conf' ] ) ? $params[ 'conf' ] : DIR_CNF . '/fiflet.conf';
        self::$mConfigData = parse_ini_file( $file, true, INI_SCANNER_NORMAL );
        self::$mConfigData[ 'config_file_path' ] = $file;
        self::$mConfigData[ 'config_directory' ] = dirname( $file );
      }
      return self::$mConfigData;
    }
  }
?>
