define( [
  'jquery',
  'mustache',
  'chart',
  'jqcloud',
  'text!templates/overview_tooltip_body.tmpl.html',
  'text!templates/overview_tooltip_footer.tmpl.html'
], function(
    $,
    mustache,
    Chart,
    jqcloud,
    tmplOverviewTooltipBody,
    tmplOverviewTooltipFooter ) {

  var charts = [];
  var $links = $( '<ul></ul>' );

  function initialize() {
    var
      userDefinedScaleDefaults = Chart.scaleService.getScaleDefaults( "linear" ),
      userDefinedScale = Chart.scaleService.getScaleConstructor( "linear" ).extend( {
        buildTicks: function() {
          this.min = 0;
          this.max = 140;
          var stepWidth = 10;
          this.ticks = [];
          for( var tickValue = this.min; tickValue <= this.max; tickValue += stepWidth ) {
            this.ticks.push( tickValue );
          }
          if( this.options.position == "left" || this.options.position == "right" ) {
            this.ticks.reverse();
          }
          if( this.options.ticks.reverse ) {
            this.ticks.reverse();
            this.start = this.max;
            this.end = this.min;
          }
          else {
            this.start = this.min;
            this.end = this.max;
          }
          this.zeroLineIndex = this.ticks.indexOf( 0 );
        }
      }),
      userDefinedScaleSmall = Chart.scaleService.getScaleConstructor( "linear" ).extend( {
        buildTicks: function() {
          this.min = 0;
          this.max = 140;
          var stepWidth = 20;
          this.ticks = [];
          for( var tickValue = this.min; tickValue <= this.max; tickValue += stepWidth ) {
            this.ticks.push( tickValue );
          }
          if( this.options.position == "left" || this.options.position == "right" ) {
            this.ticks.reverse();
          }
          if( this.options.ticks.reverse ) {
            this.ticks.reverse();
            this.start = this.max;
            this.end = this.min;
          }
          else {
            this.start = this.min;
            this.end = this.max;
          }
          this.zeroLineIndex = this.ticks.indexOf( 0 );
        }
      });
    Chart.scaleService.registerScaleType( "fifletY", userDefinedScale, userDefinedScaleDefaults );
    Chart.scaleService.registerScaleType( "fifletY_small", userDefinedScaleSmall, userDefinedScaleDefaults );

    $( '.links' ).append( $links );
    $( 'canvas.chart' ).each( loadChart );
    $( '.regen' ).click( function( e ) {
      $( 'canvas.chart' ).each( regenGraphics );
      e.preventDefault();
      return false;
    } );
  }

  function regenGraphics( i, e ) {
    var
      $e = $( e ),
      png = $e[ 0 ].toDataURL( 'image/png' ),
      filename;
    switch( $e.data( 'ajax' ) ) {
      case 'overview':
        filename = 'overview_' + $e.data( 'aggregate' ) + '_' + $e.data( 'dataset' ) + '_' + $e.data( 'order' ) + '_' + ( $e.data( 'direction' ) ? ( $e.data( 'direction' ) + '' ).toLowerCase() : 'io' ) + ( $e.data( 'suffix' ) ? '_' + $e.data( 'suffix' ) : '' ) + '.png';
        break;
      case 'timeline':
        filename = 'timeline_' + $e.data( 'aggregate' ) + '_' + ( $e.data( 'supplier' ) || 'all' ) + '_' + ( $e.data( 'direction' ) ? ( $e.data( 'direction' ) + '' ).toLowerCase() : 'io' ) + ( $e.data( 'suffix' ) ? '_' + $e.data( 'suffix' ) : '' ) + '.png';
        break;
      default:
        filename = 'gfx_unknown.png';
    }
    $.post( 'index.php', {
      gfx: png,
      name: filename } );
  }

  function loadChart( i, e ) {
    var
      $e = $( e );
    var q = $.param( $e.data() );
    if( q ) {
      $.ajax( 'index.php?' + q, {
        context: e,
        cache: false,
        success: onChartData
      } );
    }
  }

  function onChartComplete( e ) {
    debugger;
  }

  function onChartData( data ) {
    data.options.tooltips = {
      enabled: false
    };
    $( this ).each( function( i, canvas ) {
      charts.push( new Chart( canvas, data ) );
    } );
    $( this ).data( 'chartIndex', charts.length - 1 );
  }

  function onClickChart( e, info ) {
    alert( 'ok' );
  }

  function getChartTooltipTitle( items, data ) {
  }

  function getChartTooltipLabel( items, data ) {
  }

  function getChartTooltipFooter( items, data ) {
  }

  return {
    'initialize': initialize
  }

} );
