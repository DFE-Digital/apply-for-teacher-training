FROM ruby:2.6.3-alpine

RUN apk add --update build-base postgresql-dev git tzdata nodejs yarn && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone
RUN gem install rails -v '5.2.2'
RUN gem install bundler:2.0.2

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile Gemfile.lock package.json $APP_HOME/
RUN yarn install --check-files
RUN bundle install

ADD . $APP_HOME/

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
