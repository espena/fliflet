<?php

  interface IApplication {
    public function doPreOperations();
    public function tpl( $idt );
    public function doPostOperations();
  }

?>
