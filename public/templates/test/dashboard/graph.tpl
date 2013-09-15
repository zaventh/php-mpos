<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.json2.min.js"></script>
<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.dateAxisRenderer.js"></script>
<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.highlighter.js"></script>
<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.canvasTextRenderer.min.js"></script>
<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.canvasAxisLabelRenderer.min.js"></script>
<script type="text/javascript" src="{$PATH}/js/plugins/jqplot.trendline.min.js"></script>

<article class="module width_full">
  <header><h3>Graphs</h3></header>
  <div class="module_content">
	  <div id="hashrategraph" style="height:200px; width: 100%;"></div>
  </div>
  <footer>
    <p style="margin-left: 25px">Refresh interval: {$GLOBAL.config.statistics_ajax_refresh_interval|default:"10"} seconds. Hashrate based on shares submitted in the past {$INTERVAL|default:"5"} minutes.</p>
  </footer>
</article>

<script>{literal}
$(document).ready(function(){
  $.jqplot.config.enablePlugins = true;

  // Ajax API URL
  var url = "{/literal}{$smarty.server.PHP_SELF}?page=api&action=getuserhashrate&api_key={$GLOBAL.userdata.api_key}&id={$GLOBAL.userdata.id}{literal}";

  // jqPlit defaults
  var jqPlotOptions = {
    grid: { drawBorder: false, background: '#fbfbfb', shadow: false },
    seriesDefaults:{
      shadow: false,
      fill: true,
      fillAndStroke: true,
      fillAlpha: 0.3,
      fillColor: '#26a4ed',
      label: 'hashrate',
      color: '#26a4ed',
      lineWidth: 4,
      trendline: { color: '#d30000', lineWidth: 1.0, label: 'average', shadow: true },
      markerOptions: { show: true, size: 8},
      rendererOptions: { smooth: true }
    },
    legend: { show: true },
    title: 'Hashrate',
    axes: {
      yaxis:{ pad: 1.05, label: '{/literal}{$GLOBAL.hashunits.personal}{literal}', labelRenderer: $.jqplot.CanvasAxisLabelRenderer},
      xaxis:{ tickInterval: {/literal}{$GLOBAL.config.statistics_ajax_refresh_interval}{literal}, label: 'Time', labelRenderer: $.jqplot.CanvasAxisLabelRenderer, renderer: $.jqplot.DateAxisRenderer, tickOptions: { formatString: '%T' } }
    },
  };

  // Init empty graph with 0 data
  var plot1 = $.jqplot('hashrategraph', [[[]]], jqPlotOptions);

  // Store our data globally
  var storedData = Array();

  // Our refresh worker process, updated at intervals
 (function workerHashrateGraph() {
    $.ajax({
      url: url,
      dataType: "json",
      success: function(data) {
        // Start dropping out elements
        if (storedData.length > 20) { storedData.shift(); }
        storedData[storedData.length] = [new Date().getTime(), data.getuserhashrate.hashrate];
        console.log(storedData);
        if (typeof(plot1) != "undefined") plot1.replot({data: [storedData]});
      },
      complete: function() { setTimeout(workerHashrateGraph, {/literal}{($GLOBAL.config.statistics_ajax_refresh_interval * 1000)|default:"10000"}{literal}) }
    });
  })();
});
{/literal}</script>
