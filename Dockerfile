FROM ruby:2.7.4-alpine3.14 as Builder

RUN apk add --no-cache \
  build-base \
  libxml2-dev \
  libxslt-dev \
  curl \
  musl-dev \
  zip \
  openjdk7-jre && \
  mkdir /tmp/tmprt && \
  cd /tmp/tmprt && \
  unzip -q /usr/lib/jvm/default-jvm/jre/lib/rt.jar && \
  zip -q -r /tmp/rt.zip . && \
  cd /tmp && \
  mv rt.zip /usr/lib/jvm/default-jvm/jre/lib/rt.jar && \
  rm -rf /tmp/tmprt /var/cache/apk/*

COPY gemrc $HOME/.gemrc
RUN mkdir /usr/app
WORKDIR /usr/app

ADD Gemfile* /usr/app/
RUN bundle install && \
  s3_website install && \
  rm -rf /usr/local/bundle/cache/*.gem && \
  find /usr/local/bundle/gems/ -name "*.c" -delete && \
  find /usr/local/bundle/gems/ -name "*.o" -delete && \
  rm -rf Gemfile Gemfile.lock

FROM ruby:2.7.4-alpine3.14

RUN apk update --no-cache

COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/

RUN mkdir /usr/app

WORKDIR /usr/app

CMD ["/bin/sh"]
