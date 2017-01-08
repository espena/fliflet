  <section class="common">
    <a href="." id="regen" class="regen">regen-graphics</a>
    <section class="panels">

      <!--canvas
        class="chart timeline"
        data-ajax="timeline"
        data-aggregate="mean"
        data-supplier="164"
        data-direction="IO"
        data-scale="fifletY"
        data-description="Politidirektoratet, utvkiling over tid (gjennomsnitt)."
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart timeline"
        data-ajax="timeline"
        data-aggregate="median"
        data-supplier="164"
        data-direction="IO"
        data-scale="fifletY"
        data-description="Politidirektoratet, utvkiling over tid (median)."
        width="1800"
        height="900">
      </canvas -->

      <canvas
        class="chart timeline"
        data-ajax="timeline"
        data-aggregate="mean"
        data-supplier="91"
        data-direction="IO"
        data-suffix="with_milestones"
        data-scale="fifletY"
        data-description="Justis- og beredskapsdepartementet, utvkiling over tid."
        data-milestone-label="Styringsdialog-møte|Asylbarnsaken|Kritikk fra arkivverket"
        data-milestone-x-value="2014-06|2014-12|2016-07"
        data-milestone-y-value="70|70|70"
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart timeline"
        data-ajax="timeline"
        data-aggregate="median"
        data-supplier="91"
        data-direction="IO"
        data-suffix="with_milestones"
        data-scale="fifletY"
        data-description="Justis- og beredskapsdepartementet, utvkiling over tid."
        data-milestone-label="Styringsdialog-møte|Asylbarnsaken|Kritikk fra arkivverket"
        data-milestone-x-value="2014-06|2014-12|2016-07"
        data-milestone-y-value="70|70|70"
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="jour2pub"
        data-order="jour2pub"
        data-description="Gjennomsnittlig ant. virkedager mellom journalføring og publisering, januar 2015 - august 2016"
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="doc2pub"
        data-order="doc2pub"
        data-milestone-label="4 dager|8 dager"
        data-milestone-x-value="4|8"
        data-milestone-y-value="JD|JD"
        data-milestone-style="dashed|solid"
        data-description="Gjennomsnittlig ant. virkedager mellom dokumentdato og publisering, januar 2015 - august 2016"
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="doc2jourDoc2pub"
        data-order="doc2pub"
        data-milestone-label="4 dager|8 dager"
        data-milestone-x-value="4|8"
        data-milestone-y-value="JD|JD"
        data-milestone-style="dashed|solid"
        data-description="Gjennomsnittlig ant. virkedager mellom dokumentdato, journalføring og publisering, januar 2015 - august 2016"
        width="1800"
        height="900">
      </canvas>

      <canvas
        class="chart overview"
        data-ajax="overview"
        data-aggregate="mean"
        data-dataset="doc2jour"
        data-order="doc2jour"
        data-description="Gjennomsnittlig ant. virkedager mellom dokumentdato og journalføring, januar 2015 - august 2016"
        width="1800"
        height="900">
      </canvas>

      <hr />

      ##web_content_front_io##
      ##web_content_front_i##
      ##web_content_front_o##

      <hr />

  </section>
</section|>
