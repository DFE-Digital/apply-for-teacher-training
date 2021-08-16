# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:2.7.4-alpine3.12

# Stage 1: gems-node-modules, build gems and node modules.
FROM ${BASE_RUBY_IMAGE} AS gems-node-modules

RUN apk -U upgrade && \
    apk add --update --no-cache git gcc libc-dev make postgresql-dev build-base \
    libxml2-dev libxslt-dev ttf-ubuntu-font-family nodejs yarn tzdata libpq libxml2 libxslt graphviz

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    RAILS_ENV=production \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    BLAZER_DATABASE_URL=testURL \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey \
    REDIS_CACHE_URL=redis://127.0.0.1:6379

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem update --system && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 --without=development --with=production && \
    rm -rf /usr/local/bundle/cache

COPY package.json yarn.lock ./

RUN yarn install --check-files

COPY . .

RUN bundle exec rake assets:precompile && \
    rm -rf tmp/* log/* node_modules /tmp/*

# Stage 2: production, copy application code and compiled assets to base ruby image.
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
    SHA=${VERSION} \
    REDIS_CACHE_URL=redis://127.0.0.1:6379

RUN apk -U upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

WORKDIR /app

RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

COPY --from=gems-node-modules /app /app
COPY --from=gems-node-modules /usr/local/bundle/ /usr/local/bundle/

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
