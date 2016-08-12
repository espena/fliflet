<?php
  require_once( DIR_LIB . '/factory.inc.php' );
  require_once( DIR_LIB . '/configuration_file.inc.php' );
  define( 'URLFMT_CHRONOLOGICAL_LOOKUP', 'https://oep.no/search/result.html?contentSupplier=%s&searchType=chronological&dateType=publicationDate&hitsPerPage=%s&sortField=publicationdate&sortOrder=desc&Search=Search+in+records&start=%s&lang=no' );
  class Scraper {
    private $mSupplierNames;
    private $mSuppliersToMonitor;
    private $mConfig;
    public function __construct() {
      $this->mConfig = ConfigurationFile::parse();
      $this->mSupplierNames = Factory::getSuppliers( FALSE );
      $this->mSuppliersToMonitor = explode( ',', $this->mConfig[ 'fiflet' ][ 'suppliers_to_monitor' ] );
    }
    public function run() {
      libxml_use_internal_errors( true );
      foreach( $this->mSuppliersToMonitor as $supplierId ) {
        $this->scrapeSupplier( intval( $supplierId ) );
      }
    }
    private function scrapeSupplier( $supplierId ) {
      printf( "Scraping supplier ID %s: %s\n", $supplierId, $this->mSupplierNames[ $supplierId ] );
      $db = Factory::getDatabase();
      $db->insertSupplier( $supplierId, $this->mSupplierNames[ $supplierId ] );
      $pageSize = isset( $this->mConfig[ 'fiflet' ][ 'pagesize' ] ) ? intval( $this->mConfig[ 'fiflet' ][ 'pagesize' ] ) : 100;
      $pageCount = isset( $this->mConfig[ 'fiflet' ][ 'pagecount' ] ) ? intval( $this->mConfig[ 'fiflet' ][ 'pagecount' ] ) : 5;
      $maxOffset = $pageSize * $pageCount;
      printf( "%s hits per request, starting at page 1\n", $pageSize );
      for( $offset = 0; $offset < $maxOffset; $offset += $pageSize ) {
        $delay = isset( $this->mConfig[ 'fiflet' ][ 'seconds_between_requests' ] )
               ? intval( $this->mConfig[ 'fiflet' ][ 'seconds_between_requests' ] )
               : 5;
        printf( "%d scraped, waiting %d seconds...\n", $offset + $pageSize, $delay );
        sleep( $delay );
        $url = sprintf( URLFMT_CHRONOLOGICAL_LOOKUP, $supplierId, $pageSize, $offset );
        $html = file_get_contents( $url );
        $domDoc = new DOMDocument();
        $domDoc->loadHTML( $html );
        $domXPath = new DOMXPath( $domDoc );
        $tableRows = $domXPath->query( '//*[@id="content"]/tbody/tr' );
        $this->saveRows( $supplierId, $tableRows, $offset );
      }
    }
    private function saveRows( $supplierId, $tableRows, &$offset ) {
      $db = Factory::getDatabase();
      for( $i = 0; $i < $tableRows->length; $i++  ) {
        $tableRow = $tableRows->item( $i );
        $record = array(
          'id_supplier'     => $supplierId,
          'sakstittel'      => trim( $tableRow->childNodes->item(  0 )->textContent ),
          'dokumenttittel'  => trim( $tableRow->childNodes->item(  2 )->textContent ),
          'saksnr'          => trim( $tableRow->childNodes->item(  4 )->textContent ),
          'doknr'           => trim( $tableRow->childNodes->item(  6 )->textContent ),
          'virksomhet'      => trim( $tableRow->childNodes->item(  8 )->textContent ),
          'dokdato'         => trim( $tableRow->childNodes->item( 10 )->textContent ),
          'jourdato'        => trim( $tableRow->childNodes->item( 12 )->textContent ),
          'pubdato'         => trim( $tableRow->childNodes->item( 14 )->textContent ),
          'annenpart'       => trim( $tableRow->childNodes->item( 16 )->textContent ),
          'unntaksgrunnlag' => trim( $tableRow->childNodes->item( 18 )->textContent ) );
        $db->insertRecord( $record );
      }
    }
  }
?>
