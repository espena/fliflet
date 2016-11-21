<?php

  require_once( DIR_LIB . '/i_application.inc.php' );
  require_once( DIR_LIB . '/database.inc.php' );
  require_once( DIR_LIB . '/template.inc.php' );

  class AppLatex implements IApplication {

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
          echo( $this->getLatex() );
          break;
        case 'appendix_examples_row':
          $curRec = Template::getCurrentRecord();
          $tpl = new Template( 'latex_appendix_examples_row' );
          return $tpl->render( $curRec[ 'rows' ] );
        case 'overview_table_row':
          $curRec = Template::getCurrentRecord();
          $tpl = new Template( 'latex_overview_table_row' );
          return $tpl->render( $curRec[ 'rows' ] );
        default:
          return $this->mApp->tpl( $idt, $data, $returnResult );
      }
    }

    private function getLatex() {
      global $argc, $argv;
      $doc = $argc > 1 ? $argv[ 2 ] : '';
      switch( $doc ) {
        case 'appendix':
          return $this->getLatexAppendix();
        case 'appendix-examples':
          return $this->getLatexExamples();
        case 'overview-table':
          return $this->getLatexOverviewTable();
        default:
          ;
      }
    }

    private function getLatexAppendix() {
      $db = Factory::getDatabase();
      $suppliers = $db->getReportSuppliers();
      $tpl = new Template( 'latex_appendix_section' );
      return $tpl->render( $suppliers );
    }

    private function getLatexExamples() {
      $db = Factory::getDatabase();
      $examples = $db->getMostDelayed();
      $tpl = new Template( 'latex_appendix_examples' );
      return $tpl->render( $examples );
    }

    private function getLatexOverviewTable() {
      $db = Factory::getDatabase();
      $data = array( 'rows' => $db->getOverviewTable( 'doc2pub', 'doc2pub' ) );
      $tpl = new Template( 'latex_overview_table' );
      return $tpl->render( array( $data ) );
    }

    public function doPostOperations() {
      $this->mApp->doPostOperations();
    }
  }

?>
