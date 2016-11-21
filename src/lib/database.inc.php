<?php
  require_once( DIR_LIB . '/template.inc.php' );
  require_once( DIR_LIB . '/factory.inc.php' );
  class Database {
    private $mConfig;
    private $mDb;
    private $mSuppliers;
    private $mMostDelayed;
    private $mReport;
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
    public function getOverview( $dataset, $aggregate, $sortcrit, $direction = 'IO' ) {
      $sql = sprintf( "CALL getOverview( '%s', '%s', '%s', '%s' );", $dataset, $aggregate, $sortcrit, $direction );
      $this->mDb->multi_query( $sql );
      $data = array(
        'labels'   => array(),
        'datasets' => array()
      );
      $i = 0;
      while( $this->mDb->more_results() ) {
        $data[ 'datasets' ][ $i ] = array(
          'label'           => $dataset,
          'backgroundColor' => $this->mConfig[ 'chartcolors' ][ $dataset ],
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
    public function getOverviewTable( $dataset, $sortcrit, $direction = 'IO' ) {
      $sql = sprintf( "CALL getOverviewTable( '%s', '%s', '%s' );", $dataset, $sortcrit, $direction );
      $this->mDb->multi_query( $sql );
      $data = array();
      if( $this->mDb->more_results() ) {
        if( $res = $this->mDb->use_result() ) {
          while( $row = $res->fetch_assoc() ) {
            array_push( $data, $row );
          }
          $res->free();
        }
      }
      $this->flushResults();
      return $data;
    }
    public function setRecordsDirection(  ) {
      $directions = array();
      $res = $this->mDb->query( 'SELECT j.id_journal, j.second_party, s.name AS name_supplier FROM journal j NATURAL JOIN supplier s', MYSQLI_USE_RESULT );
      if( $res ) {
        while( $row = $res->fetch_assoc() ) {
          $direction = $this->findRecordDirection( $row[ 'second_party' ], $row[ 'name_supplier' ] );
          if( $direction != 'N/A' ) {
            $directions[ $row[ 'id_journal' ] ] = $direction;
          }
        }
        $res->close();
      }
      foreach( $directions as $id => $direction ) {
        $this->mDb->query( "UPDATE journal SET direction = '$direction' WHERE id_journal = $id" );
      }
    }
    private function findRecordDirection( $secondParty, $nameSupplier ) {
      preg_match( '/(TIL:\s*)(.*?)\s*?(FRA:|$)/m', $secondParty, $to );
      preg_match( '/(FRA:\s*)(.*?)\s*?(TIL:|$)/m', $secondParty, $from );
      $to = count( $to ) == 4 ? $to[ 2 ] : NULL;
      $from = count( $from ) == 4 ? $from[ 2 ] : NULL;
      if( $to && $to == $nameSupplier ) {
        $direction = 'I';
      }
      else if( $from && $from == $nameSupplier ) {
        $direction = 'O';
      }
      else if( $to && !$from ) {
        $direction = 'O';
      }
      else if( $from && !$to ) {
        $direction = 'I';
      }
      else {
        $direction = 'N/A';
      }
      return $direction;
    }
    public function getTimeline( $dataset, $aggregate, $idSupplier = 0, $direction = 'IO' ) {
      $sql = sprintf( "CALL getTimeline( '%s', '%s', %d, '%s' );", $dataset, $aggregate, $idSupplier, $direction );
      $this->mDb->multi_query( $sql );
      $data = array(
        'labels'   => array(),
        'datasets' => array()
      );
      $i = 0;
      while( $this->mDb->more_results() ) {
        /*
        $data[ 'datasets' ][ $i ] = array(
          'label'            => 'Dager totalt',
          'backgroundColor'  => 'RGBA(220,220,220,0.0)',
          'borderWidth'      => '1',
          'borderColor'      => 'RGBA(50,50,50,0.3)',
          'data'             => array() );
        */
        $data[ 'datasets' ][ $i ] = array(
          'label'            => $dataset,
          'backgroundColor'  => $this->mConfig[ 'chartcolors' ][ $dataset ],
          'borderWidth'      => '0',
          'data'             => array() );
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
    public function getMostDelayed() {
      if( empty( $this->mMostDelayed ) ) {
        $this->mMostDelayed = array();
        $this->mDb->multi_query( "CALL getMostDelayed()" );
        $i = 0;
        while( $this->mDb->more_results() ) {
          if( $res = $this->mDb->store_result() ) {
            $this->mMostDelayed[ $i ] = array(
              'rows' => array()
            );
            while( $row = $res->fetch_assoc() ) {
              if( empty( $this->mMostDelayed[ $i ][ 'longname' ] ) ) {
                $this->mMostDelayed[ $i ][ 'longname' ] = $row[ 'name' ];
                $this->mMostDelayed[ $i ][ 'shortname' ] = $row[ 'gov_body' ];
                $this->mMostDelayed[ $i ][ 'id_supplier' ] = $row[ 'id_supplier' ];
              }
              $this->mMostDelayed[ $i ][ 'rows' ][ ] = $row;
            }
            $res->free();
          }
          $i++;
          $this->mDb->next_result();
        }
      }
      return $this->mMostDelayed;
    }
    public function getTables() {
      return array(
        'table_1' => $this->getOverview( 'doc2pub', 'mean', 'doc2pub' )
      );
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
    public function getReportSuppliers() {
      if( empty( $this->mReport ) ) {
        $this->mReport = array();
        $this->mDb->multi_query( "CALL getReportSuppliers()" );
        if( $res = $this->getFirstResult() ) {
          while( $row = $res->fetch_assoc() ) {
            $this->mReport[] = $row;
          }
          $res->free();
        }
        $this->flushResults();
      }
      return $this->mReport;
    }
    public function rebasePeriod( $dateField ) {
      $this->mDb->multi_query( sprintf( "CALL rebasePeriod( '%s' )", $dateField ) );
      $this->flushResults();
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
