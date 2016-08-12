<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/template.inc.php' );

  class AppBase implements IApplication {
    public function __construct() {

    }
    public function doPreOperations() {

    }
    public function tpl( $idt ) {
      switch( $idt ) {
        case 'phpinfo':
          phpinfo();
          break;
        default:
          $t = new Template( $idt );
          echo $t->render( array() );
      }
    }
    public function doPostOperations() {

    }
  }

?>
