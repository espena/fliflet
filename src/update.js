var page = require( 'webpage' ).create();
page.open( 'http://localhost:8080', function( status ) {
  window.setTimeout( function() {
    page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
      page.evaluate( function() {
        $( '#regen' ).click();
      } );
      window.setTimeout( function() {
        phantom.exit();
      }, 20 );
    } );
  }, 10000 );
});
