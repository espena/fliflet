define( [
  'jquery',
  'mustache',
  'chart',
  'text!templates/tooltip.tmpl.html'
], function( $, mustache, Chart, tmplTooltip ) {

  function initialize() {
    $.ajax( 'index.php?ajax=overview&foo=baar3', {
      cache: false,
      success: onChartData
    } );
  }

  function onChartData( chartData ) {
    var chart = new Chart(
      $( '#overview' ),
      {
        type: 'horizontalBar',
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
          tooltips: {
            callbacks: {
              title: function( items, data ) {
                return data.longnames[ items[ 0 ].yLabel ];
              },
              label: function( items, data ) {
                var tooltipData = {
                  itemLabel: data.datasets[ items.datasetIndex ].label,
                  itemValue: data.datasets[ items.datasetIndex ].data[ items.index ],
                  lower: function() { return function( text, render ) { return render( text ).toLowerCase(); } } };
                return mustache.render( tmplTooltip, tooltipData );
              }
            }
          },
          legend: {
            position: top
          },
          title: {
            display: true,
            text: 'Journalføring og publisering i OEP, dager fra dokumentdato (gj.sn)'
          }
        }
      }
    );
  }

  return {
    'initialize': initialize
  }

} );
