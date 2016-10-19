<?php

  require_once( DIR_LIB . '/i_application.inc.php' );

  class AppWeb implements IApplication {
    private $mApp;
    public function __construct( $app ) {
      $this->mApp = $app;
    }
    public function doPreOperations() {
      $this->mApp->doPreOperations();
    }
    public function tpl( $idt, $data = null, $returnResult = false ) {
      switch( $idt ) {
        case 'main':
          return $this->mApp->tpl( 'web_main', $data, $returnResult );
        case 'content':
          if( empty( $_GET[ 'supplier' ] ) ) {
            return $this->mApp->tpl( 'web_content_front', $data, TRUE );
          }
          else {
            $db = Factory::getDatabase();
            $data = $db->getStatsSupplier( intval( $_GET[ 'supplier' ] ) );
            return $this->mApp->tpl( 'web_content_individual', $data, TRUE );
          }
        case 'web_panel_individual':
          $db = Factory::getDatabase();
          return $this->mApp->tpl( $idt, $db->getListSuppliers(), true );
        default:
          return $this->mApp->tpl( $idt, $data, true );
      }
    }
    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
  }

?>
