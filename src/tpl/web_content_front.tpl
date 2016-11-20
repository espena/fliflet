  <section class="common">
    <a href="." class="regen">regen-graphics</a>
    <section class="panels">

      <!--

      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=median&amp;supplier=164" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=mean&amp;supplier=164" width="400" height="200"></canvas>

      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=doc2pub&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
    -->
      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="jour2pub"
        data-order="jour2pub"
        data-description="Gjennomsnitt, antall virkedager mellom journalføring og publisering"
        width="900"
        height="450">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="doc2pub"
        data-order="doc2pub"
        data-milestone-value="4"
        data-milestone-label="4 dager"
        data-description="Gjennomsnitt, antall virkedager mellom dokumentdato og publisering"
        width="900"
        height="450">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="doc2jour"
        data-order="doc2jour"
        data-description="Gjennomsnitt, antall virkedager mellom dokumentdato og journalføring"
        width="900"
        height="450">
      </canvas>

      <hr />

      ##web_content_front_io##
      ##web_content_front_i##
      ##web_content_front_o##

      <hr />

      <!--
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=77" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=78" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=79" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=80" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=82" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=84" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=85" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=86" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=89" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=90" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=92" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=93" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=198" width="400" height="200"></canvas>
      <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=199" width="400" height="200"></canvas>
    -->

<!--
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;dataset=jour2pub&amp;aggregate=mean&amp;order=jour2pub" width="400" height="200"></canvas>
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;dataset=jour2pub&amp;aggregate=median&amp;order=jour2pub" width="400" height="200"></canvas>
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;dataset=jour2pub&amp;aggregate=mode&amp;order=jour2pub" width="400" height="200"></canvas>
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;aggregate=mean&amp;order=doc2pub" width="400" height="400"></canvas>
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;aggregate=median&amp;order=doc2pub" width="400" height="400"></canvas>
    <canvas class="chart overview" data-chart-options="ajax=overview&amp;aggregate=mode&amp;order=doc2pub" width="400" height="400"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=doc2jour&amp;aggregate=median" width="400" height="200"></canvas>

    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=mean" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=doc2pub&amp;aggregate=mean" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=mean" width="400" height="200"></canvas>

    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=median" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=doc2pub&amp;aggregate=median" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median" width="400" height="200"></canvas>

    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=doc2pub&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=mean&amp;supplier=91" width="400" height="200"></canvas>

    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;aggregate=median&amp;supplier=92" width="400" height="200"></canvas>

    <canvas class="chart overview" data-chart-options="ajax=overview&amp;dataset=jour2pub&amp;aggregate=median&amp;order=jour2pub&amp;supplier=91" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=median&amp;supplier=92" width="400" height="200"></canvas>
    <canvas class="chart timeline" data-chart-options="ajax=timeline&amp;dataset=jour2pub&amp;aggregate=median&amp;supplier=91" width="400" height="200"></canvas>
  -->

  </section>
</section|>
