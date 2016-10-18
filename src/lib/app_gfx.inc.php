<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/database.inc.php' );
  require_once( DIR_LIB . '/configuration_file.inc.php' );

  class AppGfx implements IApplication {

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
          $c = ConfigurationFile::parse();
          $filename = $c[ 'gfx' ][ 'export_directory' ] . '/'. $_POST[ 'name' ];
          @unlink( $filename );
          list( $type, $data ) = explode( ';', $_POST[ 'gfx' ] );
          list( , $data )      = explode( ',', $data );
          file_put_contents( $filename, base64_decode( $data ) );
          header('Content-Type: application/json');
          echo( json_encode( array( 'status' => 'ok', 'file_written' => $filename ) ) );
          break;
        default:
          return $this->mApp->tpl( $idt, $data, $returnResult );
      }
    }

    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }

  }

?>
