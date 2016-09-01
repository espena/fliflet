requirejs.config( {
  'baseUrl': 'js',
  'paths': {
    'jquery':   'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0-beta1/jquery.min',
    'mustache': 'https://cdnjs.cloudflare.com/ajax/libs/mustache.js/2.2.1/mustache.min',
    'isotope':  'https://unpkg.com/isotope-layout@3.0/dist/isotope.pkgd.min',
    'chart':    'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.2.1/Chart.bundle.min',
    'jqcloud':  'lib/jqcloud/jqcloud.min',
    'text':     'https://cdnjs.cloudflare.com/ajax/libs/require-text/2.0.12/text.min'
  },
  shim: {
    jqcloud: {
      deps: [ 'jquery' ],
      exports: 'jqcloud'
    }
  }
} );
require( [ 'modules/fiflet' ], function( fiflet ) {
  fiflet.initialize();
} );
