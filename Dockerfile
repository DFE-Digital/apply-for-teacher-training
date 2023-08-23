# To use or update to a ruby version, change {BASE_RUBY_IMAGE}
ARG BASE_RUBY_IMAGE=ruby:3.1.2-alpine3.16

# Stage 1: gems-node-modules, build gems and node modules.
FROM ${BASE_RUBY_IMAGE} AS gems-node-modules

# Create a group and user with specific UID and GID
RUN addgroup -g 1000 appgroup && adduser -u 1000 -S appuser -G appgroup

# Switch to the appuser before performing actions
USER root

RUN apk -U upgrade && \
    apk add --update --no-cache git gcc libc-dev make postgresql-dev build-base \
    libxml2-dev libxslt-dev ttf-freefont nodejs yarn tzdata libpq libxml2 libxslt graphviz

# Set the timezone to London

RUN echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

USER appuser

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

USER root

RUN chown -R appuser:appgroup /app

USER appuser
# Copy files as appuser

RUN gem update --system && \
    bundler -v && \
    bundle config set no-cache 'true' && \
    bundle config set no-binstubs 'true' && \
    bundle --retry=5 --jobs=4 --without=development && \
    rm -rf /usr/local/bundle/cache

COPY package.json yarn.lock ./

RUN yarn install --check-files

COPY . .

RUN bundle exec rake assets:precompile && \
    rm -rf tmp/* log/* node_modules /tmp/*

# Stage 2: production, copy application code and compiled assets to base ruby image.
FROM ${BASE_RUBY_IMAGE} AS production

# Add the group and user again (since this is a new build stage)
RUN addgroup -g 1000 appgroup && adduser -u 1000 -S appuser -G appgroup

# Switch to appuser
USER appuser

ENV WKHTMLTOPDF_GEM=wkhtmltopdf-binary-edge-alpine \
    LANG=en_GB.UTF-8 \
    RAILS_ENV=production \
    GOVUK_NOTIFY_API_KEY=TestKey \
    AUTHORISED_HOSTS=127.0.0.1 \
    SECRET_KEY_BASE=TestKey \
    GOVUK_NOTIFY_CALLBACK_API_KEY=TestKey \
    REDIS_CACHE_URL=redis://127.0.0.1:6379

RUN apk -U upgrade && \
    apk add --update --no-cache tzdata libpq libxml2 libxslt graphviz ttf-dejavu ttf-droid ttf-freefont ttf-liberation && \
    echo "Europe/London" > /etc/timezone && \
    cp /usr/share/zoneinfo/Europe/London /etc/localtime

WORKDIR /app

# The following line might not work for non-root users, so you may want to reconsider its use or find another way to set environment variables
RUN echo export PATH=/usr/local/bin:\$PATH > /root/.ashrc
ENV ENV="/root/.ashrc"

# Copy over files and set proper permissions
COPY --from=gems-node-modules /app /app
COPY --from=gems-node-modules /usr/local/bundle/ /usr/local/bundle/
RUN chown -R appuser:appgroup /app && chown -R appuser:appgroup /usr/local/bundle/

ARG SHA
ENV SHA=${SHA}
RUN echo ${SHA} > public/check

CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && bundle exec rails server -b 0.0.0.0
