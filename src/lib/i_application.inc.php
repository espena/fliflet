<?php

  interface IApplication {
    public function doPreOperations();
    public function tpl( $idt, $returnResult = false );
    public function doPostOperations();
  }

?>
