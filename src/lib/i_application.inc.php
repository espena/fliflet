<?php

  interface IApplication {
    public function doPreOperations();
    public function tpl( $idt, $data = null, $returnResult = false );
    public function doPostOperations();
  }

?>
