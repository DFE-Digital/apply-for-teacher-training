# See: # https://raw.githubusercontent.com/johrstrom/jmeter-prometheus-plugin/master/docs/examples/simple_prometheus_example.jmx

prometheus_xml = <<PROMETHEUS_LISTENER_CONFIG
      <com.github.johrstrom.listener.PrometheusListener guiclass="com.github.johrstrom.listener.gui.PrometheusListenerGui" testclass="com.github.johrstrom.listener.PrometheusListener" testname="Prometheus listener" enabled="true">
        <collectionProp name="prometheus.collector_definitions">
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the response time for a jsr223 sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_response_times_as_hist</stringProp>
            <stringProp name="collector.type">HISTOGRAM</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="102727412">label</stringProp>
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets">100,500,1000,3000</stringProp>
            <stringProp name="listener.collector.listen_to">samples</stringProp>
            <stringProp name="listener.collector.measuring">ResponseTime</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the response time for a jsr223 sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_response_times_as_summary</stringProp>
            <stringProp name="collector.type">SUMMARY</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="102727412">label</stringProp>
              <stringProp name="3059181">code</stringProp>
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets">0.75,0.5|0.95,0.1|0.99,0.01</stringProp>
            <stringProp name="listener.collector.measuring">ResponseTime</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the total number of samplers</stringProp>
            <stringProp name="collector.metric_name">jmeter_total_count</stringProp>
            <stringProp name="collector.type">COUNTER</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="102727412">label</stringProp>
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets"></stringProp>
            <stringProp name="listener.collector.measuring">CountTotal</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the total number of successful samplers</stringProp>
            <stringProp name="collector.metric_name">jmeter_total_success</stringProp>
            <stringProp name="collector.type">COUNTER</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="102727412">label</stringProp>
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets"></stringProp>
            <stringProp name="listener.collector.measuring">SuccessTotal</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the response size for a jsr223 sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_response_size_as_hist</stringProp>
            <stringProp name="collector.type">HISTOGRAM</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets">100,500,1000,3000</stringProp>
            <stringProp name="listener.collector.measuring">ResponseSize</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">success ratio of the can_fail_sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_success_ratio</stringProp>
            <stringProp name="collector.type">SUCCESS_RATIO</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets"></stringProp>
            <stringProp name="listener.collector.measuring">SuccessRatio</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the latency (ttfb) for a jsr223 sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_latency_as_hist</stringProp>
            <stringProp name="collector.type">HISTOGRAM</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="102727412">label</stringProp>
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets">100,500,1000,3000</stringProp>
            <stringProp name="listener.collector.measuring">Latency</stringProp>
          </elementProp>
          <elementProp name="" elementType="com.github.johrstrom.listener.ListenerCollectorConfig">
            <stringProp name="collector.help">the idle time for a jsr223 sampler</stringProp>
            <stringProp name="collector.metric_name">jmeter_idle_time</stringProp>
            <stringProp name="collector.type">SUMMARY</stringProp>
            <collectionProp name="collector.labels">
              <stringProp name="96801">app</stringProp>
              <stringProp name="96802">guid</stringProp>
              <stringProp name="96803">exported_instance</stringProp>
              <stringProp name="96804">organisation</stringProp>
              <stringProp name="96805">space</stringProp>
            </collectionProp>
            <stringProp name="collector.quantiles_or_buckets">0.75,0.5|0.95,0.1|0.99,0.01</stringProp>
            <stringProp name="listener.collector.measuring">IdleTime</stringProp>
          </elementProp>
        </collectionProp>
        <stringProp name="TestPlan.comments">This listener &quot;measures&quot; everything, sometimes in summaries, sometimes in histograms.</stringProp>
      </com.github.johrstrom.listener.PrometheusListener>
      <hashTree/>
      <Arguments guiclass="ArgumentsPanel" testclass="Arguments" testname="User Define
d Variables" enabled="true">
        <collectionProp name="Arguments.arguments">
          <elementProp name="app" elementType="Argument">
            <stringProp name="Argument.name">app</stringProp>
            <stringProp name="Argument.value">${__P(app,)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>
          <elementProp name="guid" elementType="Argument">
            <stringProp name="Argument.name">guid</stringProp>
            <stringProp name="Argument.value">${__P(guid,)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>
          <elementProp name="exported_instance" elementType="Argument">
            <stringProp name="Argument.name">exported_instance</stringProp>
            <stringProp name="Argument.value">${__P(exported_instance,)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>
          <elementProp name="organisation" elementType="Argument">
            <stringProp name="Argument.name">organisation</stringProp>
            <stringProp name="Argument.value">${__P(organisation,)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>
          <elementProp name="space" elementType="Argument">
            <stringProp name="Argument.name">space</stringProp>
            <stringProp name="Argument.value">${__P(space,)}</stringProp>
            <stringProp name="Argument.metadata">=</stringProp>
          </elementProp>
        </collectionProp>
      </Arguments>
      <hashTree/>
PROMETHEUS_LISTENER_CONFIG

output = File.open('testplan.jmx', 'w')

File.foreach('ruby-jmeter.jmx') do |line|
  if line =~ /^    <\/hashTree>$/
    output.puts(prometheus_xml)
  end

  output.puts line
end

output.close
