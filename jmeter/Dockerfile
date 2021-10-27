FROM ruby:2.7.4-alpine3.12
ARG BUILD_DEPS="git gcc libc-dev make build-base libxml2-dev libxslt-dev"

WORKDIR /app

RUN apk -U upgrade && \
    apk add --update --no-cache $BUILD_DEPS tzdata libxml2 libxslt curl unzip && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apk update && apk add openjdk11-jre-headless

ENV JMETER_VERSION="5.4.1"
ENV JMETER_MIRROR https://downloads.apache.org/jmeter/binaries
ENV JMETER_PATH /opt/apache-jmeter-${JMETER_VERSION}
RUN cd /opt && \
    curl -o apache-jmeter-${JMETER_VERSION}.tgz ${JMETER_MIRROR}/apache-jmeter-${JMETER_VERSION}.tgz && \
    curl -o apache-jmeter-${JMETER_VERSION}.tgz.sha512 ${JMETER_MIRROR}/apache-jmeter-${JMETER_VERSION}.tgz.sha512 && \
    sha512sum -c apache-jmeter-${JMETER_VERSION}.tgz.sha512 && \
    tar xzf apache-jmeter-${JMETER_VERSION}.tgz && \
    ln -s ${JMETER_PATH}/bin/jmeter /usr/local/bin

RUN cd ${JMETER_PATH} && \
    curl -o jmeter-prometheus.zip https://jmeter-plugins.org/files/packages/jmeter-prometheus-0.6.0.zip && \
    unzip jmeter-prometheus.zip

RUN cd ${JMETER_PATH} && \
    curl -o jmeter-json.zip https://jmeter-plugins.org/files/packages/jpgc-json-2.7.zip && \
    unzip -o jmeter-json.zip

EXPOSE 8080
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN mkdir plans
COPY plans/ plans/
COPY *.csv ./

ENV JMETER_TARGET_BASEURL=
ENV JMETER_TARGET_PLAN=
ENV JMETER_WAIT_FACTOR=

COPY add_prometheus_xml.rb ./
COPY run.sh ./

CMD ash ./run.sh
