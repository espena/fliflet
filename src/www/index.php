<?php

  ini_set( 'error_reporting', E_ALL );
  ini_set( 'display_errors', 1 );

  define( 'DIR_CACHE', '../cache' );

  define( 'DIR_LIB', '../lib' );
  define( 'DIR_TPL', '../tpl' );
  define( 'DIR_CNF', '../cnf' );

  require_once( DIR_LIB . '/factory.inc.php' );

  $theApp = Factory::getApp();
  $theApp->tpl( 'main' );
  Factory::releaseApp( $theApp );

?>
