# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:2.7.2-alpine3.12
# BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES will default to apply-for-teacher-training-gems-node-modules
# building all layers above it if a value is not specidied during the build
ARG BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES=apply-for-teacher-training-gems-node-modules

# Stage 1: install-gems-node-modules, download gems and node modules.
FROM ${BASE_RUBY_IMAGE} AS install-gems-node-modules

ARG BUILD_DEPS="git gcc libc-dev make nodejs yarn postgresql-dev build-base libxml2-dev libxslt-dev ttf-ubuntu-font-family"
ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine

WORKDIR /app

COPY Gemfile Gemfile.lock package.json yarn.lock ./

RUN apk -U upgrade && \
    apk add --update --no-cache --virtual .gem-installdeps $BUILD_DEPS && \
    gem update --system && \
    find / -wholename '*default/bundler-*.gemspec' -delete && \
    rm -rf /usr/local/bin/bundle && \
    gem install bundler -v 2.1.4 && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 --without=development --with=production && \
    yarn install --check-files && \
    apk del .gem-installdeps && \
    rm -rf /usr/local/bundle/cache && \
    find /usr/local/bundle/gems -name "*.c" -delete && \
    find /usr/local/bundle/gems -name "*.h" -delete && \
    find /usr/local/bundle/gems -name "*.o" -delete

# Stage 2: apply-for-teacher-training-gems-node-modules, reduce size of gems-node-modules and only keep required files.
# published as dfedigital/apply-for-teacher-training-gems-node-modules
FROM ${BASE_RUBY_IMAGE} AS apply-for-teacher-training-gems-node-modules

ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    RAILS_ENV=production \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    BLAZER_DATABASE_URL=testURL \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey

RUN apk -U upgrade && \
    apk add --update --no-cache nodejs yarn tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

COPY --from=install-gems-node-modules /app /app
COPY --from=install-gems-node-modules /usr/local/bundle/ /usr/local/bundle/

# Stage 3: assets-precompile, precomple assets and remove compile dependencies.
FROM ${BASE_RUBY_IMAGE_WITH_GEMS_AND_NODE_MODULES} AS assets-precompile

WORKDIR /app
COPY . .

RUN yarn run lint && \
    yarn run test && \
    yarn run stylelint app/frontend/styles && \
    bundle exec rake assets:precompile && \
    apk del nodejs yarn && \
    rm -rf yarn.lock && \
    rm -rf tmp/* log/* node_modules /usr/local/share/.cache /tmp/*

# Stage 4: production, copy application code and compiled assets to base ruby image.
# Depends on assets-precompile stage which can be cached from a pre-built image
# by specifying a fully qualified image name or will default to packages-prod thereby rebuilding all 3 stages above.
# If a existing base image name is specified Stage 1 & 2 will not be built and gems and dev packages will be used from the supplied image.
FROM ${BASE_RUBY_IMAGE} AS production

ARG VERSION
ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    RAILS_ENV=production \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey \
    SHA=${VERSION}

RUN apk -U upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

WORKDIR /app

COPY --from=assets-precompile /app /app
COPY --from=assets-precompile /usr/local/bundle/ /usr/local/bundle/
RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

RUN echo ${VERSION} > public/check

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
