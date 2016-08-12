<?php

  define( 'DIR_LIB', '../lib' );
  define( 'DIR_TPL', '../tpl' );
  define( 'DIR_CNF', '../cnf' );

  require_once( DIR_LIB . '/factory.inc.php' );

  $theApp = Factory::getApp();
  $theApp->tpl( 'phpinfo' );
  Factory::releaseApp( $theApp );

?>
