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

  var charts = [],
      $links = $( '<ul></ul>' );

  var originalHorizontalBarDraw = Chart.controllers.horizontalBar.prototype.draw;

  Chart.controllers.horizontalBar = Chart.controllers.horizontalBar.extend( { draw: drawHorizontalBar } );

  function drawHorizontalBar() {

    originalHorizontalBarDraw.apply( this, arguments );

    var
      ctx = this.chart.chart.ctx,
      vm = this.chart.view,
      me = this,
      ds = this.chart.config.data.datasets,
      easing = arguments[ 0 ] || 1,
      meta = me.getMeta(),
      data = meta.data,
      xScale = me.getScaleForId( meta.xAxisID );

    var
      i,
      milestones = this.chart.config.milestones || [];

    for( i = 0; i < milestones.length; i++ ) {
      var m = milestones[ i ];
      var x = xScale.getPixelForValue( m.value );
      ctx.strokeStyle = m.color;
      ctx.fillStyle = m.color;
      ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo( x,  this.chart.chartArea.top - 20 );
      ctx.lineTo( x, this.chart.chartArea.bottom + 5 );
      ctx.stroke();
      ctx.textAlign = 'end';
      ctx.fillText( m.label, x - 7, this.chart.chartArea.top - 25 );
    }

    ctx.fillStyle = '#333333';
    ctx.textAlign = 'start';
    for( var k in data ) {
      if( data.hasOwnProperty( k ) ) {
        var bar = data[ k ];
        var val = Math.round( me.getDataset().data[ k ] * 10 ) / 10;
        ctx.fillText( val, bar._model.x + 5, bar._model.y - 5 );
      }
    }
  }

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

  function onChartData( data ) {
    data.options.tooltips = {
      enabled: false
    };
    $( this ).each( function( i, canvas ) {
      var c = new Chart( canvas, data );
      charts.push( c );
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
