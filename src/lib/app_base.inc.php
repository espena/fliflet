<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/template.inc.php' );

  class AppBase implements IApplication {
    public function __construct() {

    }
    public function doPreOperations() {

    }
    public function tpl( $idt, $returnResult = false ) {
      switch( $idt ) {
        case 'phpinfo':
          phpinfo();
          break;
        default:
          $t = new Template( $idt );
          if( $returnResult ) {
            return $t->render( array() );
          }
          echo $t->render( array() );
      }
    }
    public function doPostOperations() {

    }
  }

?>
