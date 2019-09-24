FROM ruby:2.6.3-alpine

ENV APP_HOME /app
ENV GOVUK_NOTIFY_API_KEY=TestKey

RUN apk add --update build-base postgresql-dev git tzdata nodejs yarn && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

WORKDIR $APP_HOME
COPY Gemfile Gemfile.lock package.json yarn.lock $APP_HOME/

RUN gem install bundler:2.0.2 && \
    yarn install --check-files && \
    bundle install

COPY . $APP_HOME/

RUN bundle exec rake assets:precompile

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
