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
    public function tpl( $idt, $returnResult = false ) {
      switch( $idt ) {
        case 'main':
          return $this->mApp->tpl( 'web_main', $returnResult );
        case 'content':
          return $this->mApp->tpl( 'web_content_front', $returnResult );
        default:
          return $this->mApp->tpl( $idt, $returnResult );
      }
    }
    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
  }

?>
