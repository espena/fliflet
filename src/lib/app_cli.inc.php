<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/scraper.inc.php' );

  class AppCli implements IApplication {
    private $mApp;
    public function __construct( $app ) {
      $this->mApp = $app;
    }
    public function doPreOperations() {
      $this->mApp->doPreOperations();
    }
    public function tpl( $idt ) {
      switch( $idt ) {
        case 'main':
          global $argc, $argv;
          $this->mApp->tpl( 'cli_main' );
          $this->main( $argc, $argv );
          break;
        default:
          $this->mApp->tpl( $idt );
      }
    }
    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
    private function main( $argc, $argv ) {
      if( array_search( 'nuke-database', $argv ) !== FALSE ) {
        $db = Factory::getDatabase();
        $db->createDb();
        printf( "Database recreated.\n" );
      }
      else if( array_search( 'regen-suppliers', $argv ) !== FALSE ) {
        print_r( Factory::getSuppliers( TRUE ) );
      }
      else if( array_search( 'list-suppliers', $argv ) !== FALSE ) {
        print_r( Factory::getSuppliers( FALSE ) );
      }
      else if( array_search( 'scrape', $argv ) !== FALSE ) {
        $scraper = new Scraper();
        $scraper->run();
      }
    }

  }

?>
