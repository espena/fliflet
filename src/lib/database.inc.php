<?php
  require_once( DIR_LIB . '/template.inc.php' );
  require_once( DIR_LIB . '/factory.inc.php' );
  class Database {
    private $mConfig;
    private $mDb;
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
    public function getTimeline() {
      $sql =
       "SELECT
          CONCAT( YEAR( dokdato ), '-', LPAD( MONTH( dokdato ), 2, '0' ) ) AS periode,
          AVG( DATEDIFF( jourdato, dokdato ) ) AS dager_jour,
          AVG( DATEDIFF( pubdato, dokdato ) ) AS dager_pub
        FROM
          journal
        WHERE
          /*virksomhet = 'FD'
        AND*/
          dokdato > '2014-12-31'
        AND
          dokdato < jourdato
        AND
          jourdato < pubdato
        AND
          DATEDIFF( pubdato, dokdato ) < 365
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
      return array(
        'tittel' => 'Utvikling over tid, journalføring og publisering i OEP. Antall dager fra dokumentdato.',
        'container_class' => 'timeline',
        'type' => 'line',
        'labels' => $labels,
        'datasets' => array(
                        array(
                          'label' => 'Journalføring',
                          'backgroundColor' => 'rgba(151,187,205,0.5)',
                          'data' => $dataJour ),
                        array(
                          'label' => 'Publisering',
                          'backgroundColor' => 'rgba(220,220,220,0.5)',
                          'data' => $dataPub ) ) );
    }
    public function getOverview() {
      $dataJour = array();
      $dataPub = array();
      $dataTot = array();
      $labels = array();
      $longNames = array();
      $this->mDb->multi_query( "CALL statsOverview()" );
      if( $res = $this->getFirstResult() ) {
        while( $row = $res->fetch_assoc() ) {
          $labels[] = $row[ 'forkortelse' ];
          $longNames[ $row[ 'forkortelse' ] ] = $row[ 'navn' ];
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
      return array(
        'tittel' => 'Journalføring og publisering i OEP fra 1/1-2016. Gjennomsnittlig antall dager fra dokumentdato.',
        'container_class' => 'overview',
        'type' => 'horizontalBar',
        'labels' => $labels,
        'longnames' => $longNames,
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
                          'data' => $dataPub ) ) );
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
          if( $res->errorno ) {
            Factory::getLogger()->error( $res->error );
          }
          $res->free();
        }
      }
    }
  }
?>
