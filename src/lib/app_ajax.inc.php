<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/database.inc.php' );

  class AppAjax implements IApplication {
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
          header('Content-Type: application/json');
          echo( $this->getJson() );
          break;
        default:
          $this->mApp->tpl( $idt );
      }
    }
    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
    private function getJson() {
      $db = Factory::getDatabase();
      switch( $_GET[ 'ajax' ] ) {
        case 'overview':
          echo( json_encode( $db->getOverview() ) );
          break;
      }
    }
  }

?>
