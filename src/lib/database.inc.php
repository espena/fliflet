<?php
  require_once( DIR_LIB . '/template.inc.php' );
  require_once( DIR_LIB . '/factory.inc.php' );
  class Database {
    private $mConfig;
    private $mDb;
    private $mSuppliers;
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
      $record[ 'saksnr' ] = explode( '/', $record[ 'saksnr' ] );
      $record[ 'dokdato' ] = $this->isoDate( $record[ 'dokdato' ] );
      $record[ 'jourdato' ] = $this->isoDate( $record[ 'jourdato' ] );
      $record[ 'pubdato' ] = $this->isoDate( $record[ 'pubdato' ] );
      $sql = sprintf( "CALL insertRecord( %s, '%s', '%s', '%s', %s, %s, '%s', '%s', '%s', '%s', '%s', '%s' )",
                            $this->mDb->escape_string( $record[ 'id_supplier' ] ),
                            $this->mDb->escape_string( $record[ 'sakstittel' ] ),
                            $this->mDb->escape_string( $record[ 'dokumenttittel' ] ),
                            $this->mDb->escape_string( $record[ 'saksnr' ][ 0 ] ),
                            $this->mDb->escape_string( $record[ 'saksnr' ][ 1 ] ),
                            $this->mDb->escape_string( $record[ 'doknr' ] ),
                            $this->mDb->escape_string( $record[ 'virksomhet' ] ),
                            $this->mDb->escape_string( $record[ 'dokdato' ] ),
                            $this->mDb->escape_string( $record[ 'jourdato' ] ),
                            $this->mDb->escape_string( $record[ 'pubdato' ] ),
                            $this->mDb->escape_string( $record[ 'annenpart' ] ),
                            $this->mDb->escape_string( $record[ 'unntaksgrunnlag' ] ) );
      $this->mDb->multi_query( $sql );
      $this->flushResults();
    }
    public function isoDate( $dd_mm_yyyy ) {
      return sprintf( '%s-%s-%s',
                substr( $dd_mm_yyyy, 6, 4 ),
                substr( $dd_mm_yyyy, 3, 2 ),
                substr( $dd_mm_yyyy, 0, 2 ) );
    }
    public function getListSuppliers() {
      if( empty( $this->mSuppliers ) ) {
        $this->mSuppliers = array();
        $sql = "SELECT * FROM supplier ORDER BY navn";
        if( $res = $this->mDb->query( $sql ) ) {
          while( $row = $res->fetch_assoc() ) {
            $this->mSuppliers[] = $row;
          }
          $res->free();
        }
      }
      return $this->mSuppliers;
    }
    public function getStatsSupplier( $supplierId ) {
      $statsSupplier = array();
      $this->mDb->multi_query( "CALL statsOverview( $supplierId )" );
      if( $res = $this->getFirstResult() ) {
        while( $row = $res->fetch_assoc() ) {
          $statsSupplier = $row;
        }
        $res->free();
      }
      $this->flushResults();
      return $statsSupplier;
    }
    public function getTimeline( $supplierId = 0 ) {
      $supplierId = intval( $supplierId );
      $sql =
       "SELECT
          periode,
          ROUND( AVG( DATEDIFF( jourdato, dokdato ) ) ) AS dager_jour,
          ROUND( AVG( DATEDIFF( pubdato, dokdato ) ) ) AS dager_pub
        FROM
          journal
        WHERE
          ( $supplierId = 0 OR id_supplier = $supplierId )
        AND
          dokdato > '2015-12-31'
        AND
          dokdato < DATE_SUB( CURRENT_DATE(), INTERVAL 3 MONTH )
        GROUP BY
          periode
        ORDER BY
          periode ASC";
      if( $res = $this->mDb->query( $sql ) ) {
        $labels = array();
        while( $row = $res->fetch_assoc() ) {
          $labels[] = $row[ 'periode' ];
          $dataJour[] = $row[ 'dager_jour' ];
          $dataPub[] = $row[ 'dager_pub' ];
        }
        $res->free();
      }
      $title = 'Utvikling i journalføring og publisering i OEP';
      return array(
        'type' => 'line',
        'data' => array (
          'name' => 'timeline',
          'labels' => $labels,
          'datasets' => array(
            array(
              'label' => 'Journalføring',
              'backgroundColor' => 'rgba(151,187,205,0.5)',
              'data' => $dataJour ),
            array(
              'label' => 'Publisering',
              'backgroundColor' => 'rgba(220,220,220,0.5)',
              'data' => $dataPub )
          )
        ),
        'options' => array(
          'responsive' => TRUE,
          'legend' => array(
            'position' => 'top'
          ),
          'scales' => array(
            'yAxes' => array(
              array(
                'type' => 'fifletY'
              ),
            )
          ),
          'title' => array(
            'display' => TRUE,
            'text' => $title
          )
        )
      );
    }
    public function getOverview() {
      $dataJour = array();
      $dataPub = array();
      $dataTot = array();
      $labels = array();
      $longNames = array();
      $supplierIds = array();
      $this->mDb->multi_query( "CALL statsOverview( 0 )" );
      if( $res = $this->getFirstResult() ) {
        while( $row = $res->fetch_assoc() ) {
          $labels[] = $row[ 'forkortelse' ];
          $longNames[ $row[ 'forkortelse' ] ] = $row[ 'navn' ];
          $supplierIds[ $row[ 'forkortelse' ] ] = $row[ 'id_supplier' ];
          $dataJour[] = $row[ 'dager_jour' ];
          $dataPub[] = $row[ 'dager_pub' ];
          $dataTot[] = $row[ 'dager_tot' ];
          $antallDok[] = $row[ 'antall_dok' ];
          $maxMinDato[] = array(
            'max' => strftime( '%d.%m.%Y', strtotime( $row[ 'max_dato' ] ) ),
            'min' => strftime( '%d.%m.%Y', strtotime( $row[ 'min_dato' ] ) ) );
        }
        $res->free();
      }
      $this->flushResults();
      $title = 'Journalføring og publisering i OEP fra 1/1-2016. Gjennomsnittlig antall dager fra dokumentdato.';
      return array(
        'type' => 'horizontalBar',
        'data' => array(
          'name' => 'overview',
          'labels' => $labels,
          'longnames' => $longNames,
          'supplierIds' => $supplierIds,
          'antall_dok' => $antallDok,
          'max_min_dato' => $maxMinDato,
          'dager_tot' => $dataTot,
          'datasets' => array(
            array(
              'label' => 'Journalføring',
              'backgroundColor' => 'rgba(151,187,205,0.5)',
              'data' => $dataJour ),
            array(
              'label' => 'Publisering',
              'backgroundColor' => 'rgba(220,220,220,0.5)',
              'data' => $dataPub
            )
          )
        ),
        'options' => array(
          'scales' => array(
            'xAxes' => array(
              array( 'stacked' => TRUE )
            ),
            'yAxes' => array(
              array( 'stacked' => TRUE )
            )
          ),
          'title' => array(
            'display' => TRUE,
            'text' => $title
          )
        )
      );
    }
    public function regenClouds() {
      $suppliers = explode( ',', $this->mConfig[ 'fiflet' ][ 'suppliers_to_monitor' ] );
      $suppliers[] = 0;
      foreach( $suppliers as $supplierId ) {
        $cloudFile = DIR_CACHE . sprintf( "/cloud_%d.json", $supplierId );
        @unlink( $cloudFile );
        $data = $this->realRegenClouds( $supplierId );
        file_put_contents(
          $cloudFile,
          json_encode( $data ) );
      }
    }
    private function realRegenClouds( $supplierId = 0 ) {
      $data = array( array(), array() );
      $cloud = array();
      $this->mDb->multi_query( "CALL getCloudDatasets( $supplierId )" );
      if( $this->mDb->more_results() ) {
        if( $res0 = $this->mDb->store_result() ) {
          $this->cloudPopulate( $cloud, $res0, FALSE );
          $res0->free();
        }
      }
      if( $this->mDb->more_results() ) {
        if( $res1 = $this->mDb->store_result() ) {
          $this->cloudPopulate( $cloud, $res1, TRUE );
          $res1->free();
        }
      }
      $this->flushResults();
      foreach( $cloud as $text => $weight ) {
        $data[  0 ][ ] = array(
          'text' => $text,
          'weight' => $weight,
          'html' => array(
            'title' => sprintf( "%d forekomster i 10.000 dokumenter", $weight )
          ) );
      }
      $cloud = array();
      $this->mDb->multi_query( "CALL getCloudDatasetsInv( $supplierId )" );
      if( $this->mDb->more_results() ) {
        if( $res0 = $this->mDb->store_result() ) {
          $this->cloudPopulate( $cloud, $res0, FALSE );
          $res0->free();
        }
      }
      if( $this->mDb->more_results() ) {
        if( $res1 = $this->mDb->store_result() ) {
          $this->cloudPopulate( $cloud, $res1, TRUE );
          $res1->free();
        }
      }
      $this->flushResults();
      foreach( $cloud as $text => $weight ) {
        $data[  1 ][ ] = array(
          'text' => $text,
          'weight' => $weight,
          'html' => array(
            'title' => sprintf( "%d forekomster i 10.000 dokumenter", $weight )
          ) );
      }
      return $data;
    }
    private function cloudPopulate( &$cloud, &$res, $reduce = FALSE ) {
      $ignoredWords = array( 'avskjermet', 'norge', 'svar', 'notat', 'referat',
                             'utkast', 'vedr',
                             'spørsmål', 'vedrørende', 'brev', 'norsk', 'oversendelse',
                             'kopi', 'over', 'draft', 'etter', 'henvendelse', 'ingen' );
      while( $row = $res->fetch_assoc() ) {
        $words = preg_split( '/[ \-\/]+/', $row[ 'doktittel' ] );
        foreach( $words as $word ) {
          if( array_search( $word, $ignoredWords ) !== FALSE ) {
              continue;
          }
          if( strlen( $word ) > 3 && !is_numeric( $word ) ) {
            if( isset( $cloud[ $word ] ) ) {
              if( $reduce ) {
                if( $cloud[ $word ] > 1 ) {
                  $cloud[ $word ]--;
                }
                else {
                  unset( $cloud[ $word ] );
                }
              }
              else {
                $cloud[ $word ]++;
              }
            }
            else if( !$reduce ) {
              $cloud[ $word ] = 1;
            }
          }
        }
      }
      arsort( $cloud );
      if( count( $cloud ) > 500 ) {
        $cloud = array_slice( $cloud, 0, 500 );
      }
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
