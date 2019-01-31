FROM ruby:2.6.0

RUN apt-get update && apt-get install apt-transport-https

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get update && \
  apt-get install -y \
  yarn \
  nodejs

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install

ADD package.json $APP_HOME/package.json
ADD yarn.lock $APP_HOME/yarn.lock
RUN yarn

ADD . $APP_HOME/

RUN bundle exec rake assets:precompile

CMD bundle exec rails server -b 0.0.0.0
