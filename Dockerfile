#### Common Build Image Stage ####

FROM ruby:2.7.1-alpine AS common-build

ARG BUILD_DEPS="git gcc libc-dev make nodejs yarn postgresql-dev graphviz-dev graphviz-doc build-base libxml2-dev libxslt-dev ttf-ubuntu-font-family"
ARG bundleWithout=""

# These variables are required for running Rails processes like assets:precompile
ENV BUNDLE_WITHOUT=${bundleWithout} \
    WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    RAILS_ENV=test \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey

WORKDIR /app

COPY . .

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz  && \
    apk add --update --no-cache --virtual .gem-installdeps $BUILD_DEPS && \
    gem update --system && \
    find / -wholename '*default/bundler-*.gemspec' -delete && \
    rm -rf /usr/local/bin/bundle && \
    gem install bundler -v 2.1.4 && \
    bundle install --no-binstubs --retry=5 && \
    yarn install --check-files && \
    rm -rf yarn.lock && \
    bundle exec rake assets:precompile && \
    apk del .gem-installdeps && \
    rm -rf tmp log node_modules && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

FROM ruby:2.7.1-alpine AS prod-build

ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    RAILS_ENV=test \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

COPY --from=common-build /app /app
COPY --from=common-build /usr/local/bundle/ /usr/local/bundle/

WORKDIR /app

# Use this for development testing
# CMD bundle exec rails db:migrate && bundle exec rails server -b 0.0.0.0

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
