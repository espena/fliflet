<?php
  define( 'TEMPLATE_TAG_PATTERN', '/%%([^%]+)%%/' );
  define( 'TEMPLATE_INC_PATTERN', '/##([^#]+)##/' );
  define( 'TEMPLATE_FUNCTION_PATTERN', '/^([^\\(]+)\\(([^\\)]*)\\)$/' );
  class Template {
    private $mTplText;
    public function __construct( $idt ) {
      if( file_exists( $idt ) ) {
        $tplFile = $idt;
      }
      else {
        $tplFile = sprintf( '%s/%s.tpl', DIR_TPL, $idt );
      }
      $this->mTplText = file_exists( $tplFile ) ? file_get_contents( $tplFile ) : $idt;
    }
    public function render( $data ) {
      $resolved = array();
      // Expand template includes
      if( preg_match_all( TEMPLATE_INC_PATTERN, $this->mTplText, $m0, PREG_SET_ORDER ) ) {
        foreach( $m0 as $inc ) {
          if( !isset( $resolved[ $inc[ 0 ] ] ) ) {
            $tpl = new Template( $inc[ 1 ] );
            $resolved[ $inc[ 0 ] ] = $tpl->render( isset( $data[ $inc[ 1 ] ] ) ? $data[ $inc[ 1 ] ] : $data );
          }
        }
      }
      // Expand value tags
      if( preg_match_all( TEMPLATE_TAG_PATTERN, $this->mTplText, $m0, PREG_SET_ORDER ) ) {
        foreach( $m0 as $tag ) {
          $subject = $tag[ 0 ];
          if( !isset( $resolved[ $subject ] ) ) {
            $expression = trim( $tag[ 1 ] );
            $a = explode( '|', $expression );
            $n = count( $a );
            $field = trim( $a[ 0 ] );
            $functions = array();
            for( $i = 1; $i < $n; $i++ ) {
              if( preg_match( TEMPLATE_FUNCTION_PATTERN, trim( $a[ $i ] ), $m1 ) ) {
                $f = trim( $m1[ 1 ] );
                $p = trim( $m1[ 2 ] );
                $functions[ $f ] = ( $p == '' ? array() : array_map( 'trim', explode( ',', $p ) ) );
              }
            }
            $value = '';
            if( isset( $data[ $field ] ) ) {
              $value = $data[ $field ];
              foreach( $functions as $name => $params ) {
                if( function_exists( $name ) ) {
                  $value = call_user_func_array( $name, array_merge( array( $value ), $params ) );
                }
              }
            }
            $resolved[ $subject ] = $value;
          }
        }
      }
      return str_replace( array_keys( $resolved ), array_values( $resolved ), $this->mTplText );
    }
  }
?>
