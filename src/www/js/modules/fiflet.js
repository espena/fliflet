define( [
  'jquery',
  'mustache',
  'chart',
  'text!templates/overview_tooltip_body.tmpl.html',
  'text!templates/overview_tooltip_footer.tmpl.html'
], function(
    $,
    mustache,
    Chart,
    tmplOverviewTooltipBody,
    tmplOverviewTooltipFooter ) {

  var charts = [];

  function initialize() {
    $.ajax( 'index.php?ajax=overview', {
      cache: false,
      success: onChartData
    } );
    $.ajax( 'index.php?ajax=timeline', {
      cache: false,
      success: onChartData
    } );
  }

  function onChartData( chartData ) {
    var chartInfo = {
      type: chartData.type,
      data: chartData,
      options: {
        elements: {
            rectangle : {
              borderWidth: 1,
              borderColor: 'rgb(100,100,100)',
              borderSkipped: 'left'
            }
        },
        responsive: true,
        scales: {
          xAxes: [ { stacked: true } ],
          yAxes: [ { stacked: true } ]
        },
        tooltips: {
          callbacks: {
            title: function( items, data ) {
              return data.longnames[ items[ 0 ].yLabel ];
            },
            label: function( items, data ) {
              var tooltipData = {
                itemLabel: data.datasets[ items.datasetIndex ].label,
                itemValue: data.datasets[ items.datasetIndex ].data[ items.index ],
                itemTotal: data.dager_tot[ items.index ],
                lower: function() { return function( text, render ) { return render( text ).toLowerCase(); } } };
              return mustache.render( tmplOverviewTooltipBody, tooltipData ).trim().split( "\n" );
            },
            footer: function( items, data ) {
              var
                dsi = items[ 0 ].datasetIndex,
                di = items[ 0 ].index,
                footerData = {
                  n: data.antall_dok[ di ],
                  dateFirstDoc: data.max_min_dato[ di ].min,
                  dateLastDoc: data.max_min_dato[ di ].max };
              return mustache.render( tmplOverviewTooltipFooter, footerData );
            }
          }
        },
        legend: {
          position: top
        },
        title: {
          display: true,
          text: chartData.tittel
        }
      } };
    $( '.' + chartData.container_class )
      .each( function( i, e ) {
        charts.push( new Chart( e, chartInfo ) );
      } );
  }

  return {
    'initialize': initialize
  }

} );
