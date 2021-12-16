if [ -z "$JMETER_TARGET_PLAN" ]; then exit 1; fi

bundle exec ruby plans/$JMETER_TARGET_PLAN.rb && \
  bundle exec ruby add_prometheus_xml.rb && \
    jmeter -Dlog4j2.formatMsgNoLookups=true \
    -Japp=$JMETER_TARGET_APP -Jguid=$CF_INSTANCE_GUID -Jorganisation=dfe \
    -Jspace=$JMETER_TARGET_APP_SPACE -Jinstance=$CF_INSTANCE_INTERNAL_IP:8080 -Jexported_instance=$CF_INSTANCE_INDEX \
    -Jprometheus.ip=0.0.0.0 -Jprometheus.save.jvm=false \
    -Jprometheus.port=8080 -Jprometheus.delay=120 -n -t testplan.jmx
