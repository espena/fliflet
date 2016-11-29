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

  var
    originalHorizontalBarDraw = Chart.controllers.horizontalBar.prototype.draw,
    originalLineChartDraw = Chart.controllers.line.prototype.draw;

  Chart.controllers.horizontalBar = Chart.controllers.horizontalBar.extend( { draw: drawHorizontalBar } );
  Chart.controllers.line = Chart.controllers.line.extend( { draw: drawLineChart } );

  function drawHorizontalBar() {
    originalHorizontalBarDraw.apply( this, arguments );
    var
      ctx = this.chart.chart.ctx,
      data = this.getMeta().data;
    if( typeof this.chart.config.milestones !== 'undefined' ) {
      drawMilestones( this );
    }
    ctx.fillStyle = '#333333';
    ctx.textAlign = 'start';
    for( var k in data ) {
      if( data.hasOwnProperty( k ) ) {
        var
          bar = data[ k ],
          val = Math.round( this.getDataset().data[ k ] * 10 ) / 10;
        ctx.fillText( val, bar._model.x + 5, bar._model.y - 7 );
      }
    }
  }

  function drawLineChart() {
    originalLineChartDraw.apply( this, arguments );
    if( typeof this.chart.config.milestones !== 'undefined' ) {
      drawMilestones( this );
    }
  }

  function drawMilestones( me ) {
    var
      chart = me.chart,
      ctx = chart.chart.ctx,
      meta = me.getMeta(),
      xScale = me.getScaleForId( meta.xAxisID ),
      yScale = me.getScaleForId( meta.yAxisID ),
      i;
    for( i = 0; i < chart.config.milestones.length; i++ ) {
      var
        m = chart.config.milestones[ i ],
        x = xScale.getPixelForValue( m.xvalue ),
        y = yScale.getPixelForValue( m.yvalue );
      ctx.strokeStyle = m.color;
      ctx.fillStyle = m.color;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo( x,  y - 5 );
      ctx.lineTo( x, chart.chartArea.bottom + 6 );
      ctx.stroke();
      ctx.textAlign = 'end';
      ctx.fillText( m.label, x - 7, y - 13 );
    }
  }

  function initialize() {
    var
      userDefinedScaleDefaults = Chart.scaleService.getScaleDefaults( "linear" ),
      userDefinedScale = Chart.scaleService.getScaleConstructor( "linear" ).extend( {
        buildTicks: function() {
          this.min = 0;
          this.max = 80;
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
          this.max = 80;
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
