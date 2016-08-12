define( [
  'jquery',
  'mustache',
  'chart',
  'text!templates/panel.tmpl.html'
], function( $, mustache, Chart, tmplPanel ) {

  function initialize() {
    $( '.panels' ).append( tmplPanel );
  }

  return {
    'initialize': initialize
  }

} );
