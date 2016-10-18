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
    private function callReflectedGetJson( $param ) {
      $method = debug_backtrace()[ 1 ][ 'function' ] . ( empty( $_GET[ $param ] ) ? 'Error' : preg_replace( '/[^a-z0-9]+/i', '', ucfirst( $_GET[ $param ] ) ) );
      if( method_exists( $this, $method ) ) {
        return $this->$method();
      }
      else {
        return $this->getJsonError();
      }
    }
    private function getJson() {
      return json_encode( $this->callReflectedGetJson( 'ajax' ) );
    }
    private function getJsonTimeline() {
      if( empty( $_GET[ 'dataset' ] ) ) {
        $tmpData = array();
        $jsonData = $this->getJsonTimelineDoc2jour();
        $tmpData[] = $this->getJsonTimelineDoc2pub();
        foreach( $tmpData as $v ) {
          $jsonData[ 'data' ][ 'datasets' ][] = $v[ 'data' ][ 'datasets' ][ 0 ];
        }
      }
      else {
        $jsonData = $this->callReflectedGetJson( 'dataset' );
      }
      $jsonData[ 'type' ] = 'line';
      return $jsonData;
    }
    private function getJsonTimelineDoc2Jour() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonTimelineJour2Pub() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonTimelineDoc2Pub() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonTimelineDoc2jourMean() {
      return $this->getTimeline( 'doc2jour', 'mean' );
    }
    private function getJsonTimelineDoc2jourMedian() {
      return $this->getTimeline( 'doc2jour', 'median' );
    }
    private function getJsonTimelineDoc2jourMode() {
      return $this->getTimeline( 'doc2jour', 'mode_v' );
    }
    private function getJsonTimelineJour2pubMean() {
      return $this->getTimeline( 'doc2pub', 'mean' );
    }
    private function getJsonTimelineJour2pubMedian() {
      return $this->getTimeline( 'jour2pub', 'median' );
    }
    private function getJsonTimelineJour2pubMode() {
      return $this->getTimeline( 'jour2pub', 'mode_v' );
    }
    private function getJsonTimelineDoc2pubMean() {
      return $this->getTimeline( 'doc2pub', 'mean' );
    }
    private function getJsonTimelineDoc2pubMedian() {
      return $this->getTimeline( 'doc2pub', 'median' );
    }
    private function getJsonTimelineDoc2pubMode() {
      return $this->getTimeline( 'doc2pub', 'mode_v' );
    }
    private function getIdSupplier() {
      return empty( $_GET[ 'supplier' ] ) ? 0 : intval( $_GET[ 'supplier' ] );
    }
    private function getNameSupplier() {
      $suppliers = Factory::getSuppliers( FALSE );
      $idSupplier = $this->getIdSupplier();
      return isset( $suppliers[ $idSupplier ] ) ? $suppliers[ $idSupplier ] : 'Alle';
    }
    private function getJsonOverview() {
      if( empty( $_GET[ 'dataset' ] ) ) {
        $tmpData = array();
        $jsonData = $this->getJsonOverviewDoc2jour();
        $tmpData[] = $this->getJsonOverviewJour2pub();
        $tmpData[] = $this->getJsonOverviewDoc2pub();
        foreach( $tmpData as $v ) {
          $jsonData[ 'data' ][ 'datasets' ][] = $v[ 'data' ][ 'datasets' ][ 0 ];
        }
        switch( $_GET[ 'aggregate' ] ) {
          case 'mode':
            $aggregate = 'mode_v';
            break;
          default:
            $aggregate = $_GET[ 'aggregate' ];
        }
        $tit = $_GET[ '' ];
        $jsonData[ 'options' ][ 'title' ][ 'text' ] = $tit;
      }
      else {
        $jsonData = $this->callReflectedGetJson( 'dataset' );
      }
      $jsonData[ 'type' ] = 'horizontalBar';
      return $jsonData;
    }
    private function getJsonOverviewMean() {
      return $this->getOverview( '', 'mean' );
    }
    private function getJsonOverviewMedian() {
      return $this->getOverview( '', 'median' );
    }
    private function getJsonOverviewMode() {
      return $this->getOverview( '', 'mode_v' );
    }
    private function getJsonOverviewDoc2jour() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonOverviewJour2pub() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonOverviewDoc2pub() {
      return $this->callReflectedGetJson( 'aggregate' );
    }
    private function getJsonOverviewDoc2jourMean() {
      return $this->getOverview( 'doc2jour', 'mean' );
    }
    private function getJsonOverviewDoc2jourMedian() {
      return $this->getOverview( 'doc2jour', 'median' );
    }
    private function getJsonOverviewDoc2jourMode() {
      return $this->getOverview( 'doc2jour', 'mode_v' );
    }
    private function getJsonOverviewJour2pubMean() {
      return $this->getOverview( 'jour2pub', 'mean' );
    }
    private function getJsonOverviewJour2pubMedian() {
      return $this->getOverview( 'jour2pub', 'median' );
    }
    private function getJsonOverviewJour2pubMode() {
      return $this->getOverview( 'jour2pub', 'mode_v' );
    }
    private function getJsonOverviewDoc2pubMean() {
      return $this->getOverview( 'doc2pub', 'mean' );
    }
    private function getJsonOverviewDoc2pubMedian() {
      return $this->getOverview( 'doc2pub', 'median' );
    }
    private function getJsonOverviewDoc2pubMode() {
      return $this->getOverview( 'doc2pub', 'mode_v' );
    }
    private function getOverview( $dataset, $aggregate ) {
      $db = Factory::getDatabase();
      $tit = $_GET[ 'description' ];
      $direction = empty( $_GET[ 'direction' ] ) ? 'IO' : $_GET[ 'direction' ];
      $sortcrit = empty( $_GET[ 'order' ] ) ? 'doc2pub' : preg_replace( '/[^a-z0-9]/', '', $_GET[ 'order' ] );
      $jsonData = array();
      $jsonData[ 'data' ] = $db->getOverView( $dataset, $aggregate, $sortcrit, $direction );
      $jsonData[ 'options' ] = array(
        'title' => array(
          'display' => TRUE,
          'text' => $tit ),
        'scales' => array(
          'xAxes' => array(
            array(
              'ticks' => array( 'beginAtZero' => TRUE )
            ) ) ) );
      return $jsonData;
    }
    private function getTimeline( $dataset, $aggregate ) {
      $db = Factory::getDatabase();
      $tit = $_GET[ 'description' ];
      $direction = empty( $_GET[ 'direction' ] ) ? 'IO' : $_GET[ 'direction' ];
      $jsonData = array();
      $jsonData[ 'data' ] = $db->getTimeline( $dataset, $aggregate, $this->getIdSupplier(), $direction );
      $jsonData[ 'options' ] = array(
        'elements' => array(
          'point' => array(
            'radius' => 0
          )
        ),
        'showXLabels' => 3,
        'title' => array(
          'display' => TRUE,
          'text' => $tit,
        ),
        'scales' => array(
          'yAxes' => array(
            array(
              'type' => 'fifletY'
            ) ) ) );
      return $jsonData;
    }
    private function getJsonError() {
      return array( 'error' => 'Operation not defined or permitted.' );
    }
  }

?>
