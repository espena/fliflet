<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/template.inc.php' );

  class AppBase implements IApplication {
    public function __construct() {

    }
    public function doPreOperations() {

    }
    public function tpl( $idt, $data = null, $returnResult = false ) {
      switch( $idt ) {
        case 'phpinfo':
          phpinfo();
          break;
        default:
          $t = new Template( $idt );
          $html = $t->render( $data ? $data : array() );
          if( $returnResult ) {
            return $html;
          }
          echo $html;
      }
    }
    public function doPostOperations() {

    }
  }

?>
