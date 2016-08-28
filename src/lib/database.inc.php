<?php
  require_once( DIR_LIB . '/template.inc.php' );
  require_once( DIR_LIB . '/factory.inc.php' );
  class Database {
    private $mConfig;
    private $mDb;
    private $mSuppliers;
    private $mColorCodes = array(
      'doc2jour' => 'rgba( 150, 180, 150, 0.5 )',
      'jour2pub' => 'rgba( 151, 187, 205, 0.5 )',
      'doc2pub'  => 'rgba( 200, 120, 120, 0.5 )' );
    public function __construct( $config ) {
      $this->mConfig = $config;
      if( isset( $this->mConfig[ 'mysql' ] ) ) {
        $c = $this->mConfig[ 'mysql' ];
        try {
          $this->mDb =
            new MySQLi(
              $c[ 'host' ],
              $c[ 'user' ],
              $c[ 'password' ],
              '',
              isset( $c[ 'port' ] ) ? $c[ 'port' ] : '3306' );
          if( !$this->mDb->select_db( $c[ 'database' ] ) ) {
            $this->createDb();
          }
          $this->mDb->multi_query( "SET NAMES 'UTF8'" );
          $this->flushResults();
        }
        catch( Exception $e ) {
          Factory::getLogger()->error( $e->getMessage() );
          exit();
        }
      }
    }
    public function createDb() {
      $tpl = new Template( DIR_CNF . '/db/create.tpl.sql' );
      $this->mDb->multi_query( $tpl->render( $this->mConfig[ 'mysql' ] ) );
      $this->flushResults();
    }
    public function insertSupplier( $supplierId, $supplierName ) {
      $sql = sprintf( "CALL insertSupplier( %s, '%s' )", $supplierId, $supplierName );
      $this->mDb->multi_query( $sql );
      $this->flushResults();
    }
    public function insertRecord( $record ) {
      $record[ 'case_num' ] = explode( '/', $record[ 'case_num' ] );
      $record[ 'direction' ] = 'N/A';
      $record[ 'doc_date' ] = $this->isoDate( $record[ 'doc_date' ] );
      $record[ 'jour_date' ] = $this->isoDate( $record[ 'jour_date' ] );
      $record[ 'pub_date' ] = $this->isoDate( $record[ 'pub_date' ] );
      $sql = sprintf( "CALL insertRecord( %s, '%s', '%s', '%s', %s, %s, '%s', '%s', '%s', '%s', %s, '%s', '%s', '%s' )",
                            $this->mDb->escape_string( $record[ 'id_supplier' ] ),
                            $this->mDb->escape_string( $record[ 'case_title' ] ),
                            $this->mDb->escape_string( $record[ 'doc_title' ] ),
                            $this->mDb->escape_string( $record[ 'case_num' ][ 0 ] ),
                            $this->mDb->escape_string( $record[ 'case_num' ][ 1 ] ),
                            $this->mDb->escape_string( $record[ 'doc_num' ] ),
                            $this->mDb->escape_string( $record[ 'virksomhet' ] ),
                            $this->mDb->escape_string( $record[ 'doc_date' ] ),
                            $this->mDb->escape_string( $record[ 'jour_date' ] ),
                            $this->mDb->escape_string( $record[ 'pub_date' ] ),
                            $record[ 'second_party' ] == 'Internt' ? 'TRUE' : 'FALSE',
                            $this->mDb->escape_string( $record[ 'direction' ] ),
                            $this->mDb->escape_string( $record[ 'second_party' ] ),
                            $this->mDb->escape_string( $record[ 'exception_basis' ] ) );
      $success = $this->mDb->multi_query( $sql );
      if( !$success ) {
        echo( $this->mDb->error );
        echo( $sql );
        echo( "\n\n" );
      }
      $this->flushResults();
    }
    public function isoDate( $dd_mm_yyyy ) {
      return sprintf( '%s-%s-%s',
                substr( $dd_mm_yyyy, 6, 4 ),
                substr( $dd_mm_yyyy, 3, 2 ),
                substr( $dd_mm_yyyy, 0, 2 ) );
    }
    public function getOverview( $dataset, $aggregate, $sortcrit ) {
      $sql = sprintf( "CALL getOverview( '%s', '%s', '%s' );", $dataset, $aggregate, $sortcrit );
      $this->mDb->multi_query( $sql );
      $data = array(
        'labels'   => array(),
        'datasets' => array()
      );
      $i = 0;
      while( $this->mDb->more_results() ) {
        $data[ 'datasets' ][ $i ] = array(
          'label'           => $dataset,
          'backgroundColor' => $this->mColorCodes[ $dataset ],
          'borderWidth'     => '0',
          'data'            => array() );
        if( $res = $this->mDb->use_result() ) {
          while( $row = $res->fetch_assoc() ) {
            if( $i == 0 ) {
              $data[ 'labels' ][] = $row[ 'label' ];
            }
            $data[ 'datasets' ][ $i ][ 'data' ][] = $row[ 'value' ];
          }
          $res->free();
        }
        $i++;
        $this->mDb->next_result();
      }
      return $data;
    }
    public function getTimeline( $dataset, $aggregate, $idSupplier = 0 ) {
      $sql = sprintf( "CALL getTimeline( '%s', '%s', %d );", $dataset, $aggregate, $idSupplier );
      $this->mDb->multi_query( $sql );
      $data = array(
        'labels'   => array(),
        'datasets' => array()
      );
      $i = 0;
      while( $this->mDb->more_results() ) {
        $data[ 'datasets' ][ $i ] = array(
          'label'           => $dataset,
          'backgroundColor' => $this->mColorCodes[ $dataset ],
          'borderWidth'     => '0',
          'data'            => array() );
        if( $res = $this->mDb->use_result() ) {
          while( $row = $res->fetch_assoc() ) {
            if( $i == 0 ) {
              $data[ 'labels' ][] = $row[ 'label' ];
            }
            $data[ 'datasets' ][ $i ][ 'data' ][] = $row[ 'value' ];
          }
          $res->free();
        }
        $i++;
        $this->mDb->next_result();
      }
      return $data;
    }
    public function getListSuppliers() {
      if( empty( $this->mSuppliers ) ) {
        $this->mSuppliers = array();
        $this->mDb->multi_query( "CALL getListSuppliers()" );
        if( $res = $this->getFirstResult() ) {
          while( $row = $res->fetch_assoc() ) {
            $this->mSuppliers[] = $row;
          }
          $res->free();
        }
        $this->flushResults();
      }
      return $this->mSuppliers;
    }
    public function regenStatistics() {
      $this->mDb->multi_query( "CALL regenStatistics()" );
      $this->flushResults();
    }
    private function getFirstResult() {
      $res = null;
      if( $this->mDb->more_results() ) {
        $res = $this->mDb->store_result();
      }
      return $res;
    }
    private function flushResults() {
      while( $this->mDb->more_results() ) {
        $this->mDb->next_result();
        if( $res = $this->mDb->store_result() ) {
          if( $this->mDb->error ) {
            Factory::getLogger()->error( $this->mDb->error );
          }
          $res->free();
        }
      }
    }
  }
?>
