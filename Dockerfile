#### Common Build Image Stage ####

FROM ruby:2.6.3-alpine AS common-build-env

ARG APP_HOME=/app
ARG BUILD_PACKAGES="build-base"
ARG DEV_PACKAGES="postgresql-dev git nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ARG bundleWithout=""

ENV BUNDLER_VERSION="2.0.2"
ENV BUNDLE_PATH="/gems"
ENV BUNDLE_WITHOUT=${bundleWithout}

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES && \
    gem update --system && \
    find / -wholename '*default/bundler-*.gemspec' -delete && \
    rm /usr/local/bin/bundle && \
    rm /usr/local/bin/bundler && \
    gem install bundler -v $BUNDLER_VERSION

WORKDIR $APP_HOME
    
COPY Gemfile Gemfile.lock package.json yarn.lock ./

RUN bundle install && \
    yarn install


#### Dev build builds on common build env image ####

FROM common-build-env AS dev-build
ARG APP_HOME=/app
ENV RAILS_ENV=development

WORKDIR $APP_HOME

COPY . .

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0


#### Prod minify stage builds the app on the common build env image ####

FROM common-build-env AS prod-minify

ARG APP_HOME=/app

ENV RAILS_ENV=production
# These variables are required for running Rails processes like assets:precompile
ENV GOVUK_NOTIFY_API_KEY=TestKey
ENV DOMAIN=dummy.build.domain
ENV STAGING_DOMAIN=dummy.build.domain
ENV GOVUK_DOMAIN=dummy.build.domain
ENV SECRET_KEY_BASE=TestKey

WORKDIR $APP_HOME

RUN rm -rf $BUNDLE_PATH/cache/*.gem && \
    find $BUNDLE_PATH/gems/ -name "*.c" -delete && \
    find $BUNDLE_PATH/gems/ -name "*.h" -delete && \
    find $BUNDLE_PATH/gems/ -name "*.o" -delete

COPY . .

RUN bundle exec rake assets:precompile

RUN rm -rf tmp/cache app/assets lib/assets vendor/assets node_modules


#### Production image builds from scratch and copies the build app components from the prod minify stage ####

FROM ruby:2.6.3-alpine AS prod-build
ARG bundleWithout=""
ARG APP_HOME=/app
ARG PACKAGES="tzdata postgresql-client"

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=${bundleWithout}
ENV BUNDLE_PATH="/gems"
ENV BUNDLER_VERSION="2.0.2"

WORKDIR $APP_HOME

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache $PACKAGES && \
    gem update --system && \
    find / -wholename '*default/bundler-*.gemspec' -delete && \
    rm /usr/local/bin/bundle && \
    rm /usr/local/bin/bundler && \
    gem install bundler -v $BUNDLER_VERSION && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
    echo "Europe/London" > /etc/timezone

COPY --from=prod-minify $APP_HOME $APP_HOME
COPY --from=prod-minify $BUNDLE_PATH $BUNDLE_PATH

CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0
