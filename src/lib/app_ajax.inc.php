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
    public function tpl( $idt, $data = null, $returnResult = false ) {
      switch( $idt ) {
        case 'main':
          header('Content-Type: application/json');
          echo( $this->getJson() );
          break;
        default:
          return $this->mApp->tpl( $idt, $data, $returnResult );
      }
    }
    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
    private function getJson() {
      $db = Factory::getDatabase();
      switch( $_GET[ 'ajax' ] ) {
        case 'overview':
          $variant = empty( $_GET[ 'variant' ] ) ? 'average' : $_GET[ 'variant' ];
          switch( $variant ) {
            case 'median':
              $json = json_encode( $db->getOverviewMedians() );
              break;
            case 'mode':
              $json = json_encode( $db->getOverviewModes() );
              break;
            default:
              $json = json_encode( $db->getOverviewAverages() );
          }
          echo( $json );
          break;
        case 'timeline':
          echo( json_encode( $db->getTimeline( isset( $_GET[ 'supplier' ] ) ? intval( $_GET[ 'supplier' ] ) : 0 ) ) );
          break;
        case 'cloud':
          $supplierId = isset( $_GET[ 'supplier' ] ) ? intval( $_GET[ 'supplier' ] ) : 0;
          $cloudJson = DIR_CACHE . sprintf( "/cloud_%d.json", $supplierId );
          if( !file_exists( $cloudJson ) ) {
            $db->regenClouds();
          }
          echo( file_get_contents( $cloudJson ) );
          break;
      }
    }
  }

?>
