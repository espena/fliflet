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

  function initialize() {
    var
      userDefinedScaleDefaults = Chart.scaleService.getScaleDefaults( "linear" ),
      userDefinedScale = Chart.scaleService.getScaleConstructor( "linear" ).extend( {
      buildTicks: function() {
        this.min = 0;
        this.max = 70;
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
    });
    Chart.scaleService.registerScaleType( "fifletY", userDefinedScale, userDefinedScaleDefaults );
    $( 'canvas.chart' ).each( loadChart );
    $( '.cloud' ).each( loadCloud );
  }

  function loadCloud( i, e ) {
    $.ajax( 'index.php', {
      context: e,
      data: {
        ajax: 'cloud',
        supplier: $( e ).data( 'supplier' ) || ''
      },
      cache: false,
      success: onCloudData
    } );
  }

  function loadChart( i, e ) {
    var
      $e = $( e );
    $.ajax( 'index.php', {
      context: e,
      data: {
        ajax: $e.data( 'chart-type' ) || 'overview',
        supplier: $e.data( 'supplier' ) || ''
      },
      cache: false,
      success: onChartData
    } );
  }

  function onCloudData( data ) {
    var $e = $( this );
    $e.jQCloud( data[ $e.data( 'cloud-index' ) ], { width: $e.width(), height: $e.height() } );
  }

  function onChartData( data ) {
    data.options.tooltips = {
      callbacks: {
        title: getChartTooltipTitle,
        label: getChartTooltipLabel,
        footer: getChartTooltipFooter
      }
    };
    data.options.onClick = onClickChart;
    $( this ).each( function( i, canvas ) {
      charts.push( new Chart( canvas, data ) );
    } );
    $( this ).data( 'chartIndex', charts.length - 1 );
  }

  function onClickChart( e, info ) {
    if( info.length > 0 ) {
      var
        chIdx = $( e.target ).data( 'chartIndex' ),
        chart = charts[ chIdx ],
        label = chart.data.labels[ info[ 0 ]._index ],
        supplierId = chart.data.supplierIds[ label ];
      window.location = '?supplier=' + supplierId;
    }
  }

  function getChartTooltipTitle( items, data ) {
    switch( data.name ) {
      case 'overview':
        return data.longnames[ items[ 0 ].yLabel ];
      default:
        return data.labels[ items[ 0 ].index ];
    }
  }

  function getChartTooltipLabel( items, data ) {
    switch( data.name ) {
      case 'overview':
        var tooltipData = {
          itemLabel: data.datasets[ items.datasetIndex ].label,
          itemValue: data.datasets[ items.datasetIndex ].data[ items.index ],
          itemTotal: data.dager_tot[ items.index ] };
        return mustache.render( tmplOverviewTooltipBody, tooltipData ).trim().split( "\n" );
      case 'timeline':
        return data.datasets[ items.datasetIndex ].label + ': ' + data.datasets[ items.datasetIndex ].data[ items.index ] + ' dager';
      default:
        return data.datasets[ items.datasetIndex ].label + ': ' + data.datasets[ items.datasetIndex ].data[ items.index ];
    }
  }

  function getChartTooltipFooter( items, data ) {
    switch( data.name ) {
      case 'overview':
        var
          dsi = items[ 0 ].datasetIndex,
          di = items[ 0 ].index,
          footerData = {
            n: data.antall_dok[ di ],
            dateFirstDoc: data.max_min_dato[ di ].min,
            dateLastDoc: data.max_min_dato[ di ].max };
        return mustache.render( tmplOverviewTooltipFooter, footerData );
      default:
        return '';
    }
  }

  return {
    'initialize': initialize
  }

} );
