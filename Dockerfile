#### Common Build Image Stage ####

FROM ruby:2.6.5-alpine AS common-build-env

ARG APP_HOME=/app
ARG BUILD_PACKAGES="build-base"
ARG DEV_PACKAGES="postgresql-dev git nodejs yarn graphviz"
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
ENV AUTHORISED_HOSTS=dummy.build.domain
ENV SECRET_KEY_BASE=TestKey
ENV GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey

WORKDIR $APP_HOME

RUN rm -rf $BUNDLE_PATH/cache/*.gem && \
    find $BUNDLE_PATH/gems/ -name "*.c" -delete && \
    find $BUNDLE_PATH/gems/ -name "*.h" -delete && \
    find $BUNDLE_PATH/gems/ -name "*.o" -delete

COPY . .

RUN bundle exec rake assets:precompile

RUN rm -rf tmp/cache app/assets lib/assets vendor/assets node_modules


#### Production image builds from scratch and copies the build app components from the prod minify stage ####

FROM ruby:2.6.5-alpine AS prod-build
ARG bundleWithout=""
ARG APP_HOME=/app
ARG PACKAGES="tzdata postgresql-client graphviz"

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

# We migrate and ignore concurrent_migration_exceptions because we deploy to
# multiple instances at the same time.
#
# Under these conditions each instance will try to run migrations. Rails uses a
# database lock to prevent them stepping on each another. If they happen to,
# a ConcurrentMigrationError exception is thrown, the command exits 1, and
# the server will not start thanks to the shell &&.
#
# We swallow the exception and run the server anyway, because we prefer running
# new code on an old schema (which will be updated a moment later) to running
# old code on the new schema (which will require another deploy or other manual
# intervention to correct).
CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && bundle exec rails server -b 0.0.0.0
