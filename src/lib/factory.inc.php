<?php

  require_once( DIR_LIB . '/database.inc.php' );
  require_once( DIR_LIB . '/app_base.inc.php' );
  require_once( DIR_LIB . '/app_cli.inc.php' );
  require_once( DIR_LIB . '/app_web.inc.php' );
  require_once( DIR_LIB . '/app_ajax.inc.php' );
  require_once( DIR_LIB . '/app_latex.inc.php' );

  class Factory {
    private static $mApp;
    private static $mDatabase;
    private static $mParams;
    public static function getApp() {
      if( empty( self::$mApp ) ) {
        self::$mApp = new AppBase();
        if( PHP_SAPI == 'cli' ) {
          global $argc, $argv;
          self::$mApp = new AppCli( self::$mApp );
          if( $argc > 1 && $argv[ 1 ] == 'latex' ) {
            self::$mApp = new AppLatex( self::$mApp );
          }
        }
        else {
          self::$mApp = new AppWeb( self::$mApp );
          if( isset( $_GET[ 'ajax' ] ) ) {
            self::$mApp = new AppAjax( self::$mApp );
          }
        }
      }
      return self::$mApp;
    }
    public static function releaseApp( &$app ) {
      if( isset( $app ) && $app === self::$mApp ) {
        self::$mApp->doPostOperations();
        self::$mApp = null;
      }
      $app = null;
    }
    public static function getParameters() {
      if( empty( self::$mParams ) ) {
        self::$mParams = PHP_SAPI == 'cli' ? getopt( "c", array( 'conf:' ) ) : $_GET;
      }
      return self::$mParams;
    }
    public static function getSuppliers( $regen ) {
      $suppliersFile = DIR_CACHE . '/suppliers.txt';
      if( $regen || !file_exists( $suppliersFile ) ) {
        @unlink( $suppliersFile );
        $suppliers = array();
        $html = file_get_contents( 'https://oep.no/search/chronologicalSearch.jsp?&lang=nb' );
        if( preg_match_all( "/<option value='(\\d+)' label='([^\\']+)'>/", $html, $m, PREG_SET_ORDER ) ) {
          foreach( $m as $supplier ) {
            $suppliers[ $supplier[ 1 ] ] = $supplier[ 2 ];
          }
          asort( $suppliers );
          file_put_contents( $suppliersFile, serialize( $suppliers ) );
        }
      }
      else {
        $suppliers = unserialize( file_get_contents( $suppliersFile ) );
      }
      return $suppliers;
    }
    public static function getDatabase() {
      if( !self::$mDatabase ) {
        self::$mDatabase = new Database( ConfigurationFile::parse() );
      }
      return self::$mDatabase;
    }
  }
?>
