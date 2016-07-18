FROM alpine:3.4
MAINTAINER ayumi@entelo.com

RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata \
    libxml2-dev libxslt-dev

ADD examples/rhea-rails/Gemfile /app/
ADD examples/rhea-rails/Gemfile.lock /app/

RUN apk --update add --virtual build-dependencies build-base git \
    libc-dev linux-headers ruby-dev openssl-dev && \
    gem install bundler && \
    cd /app; bundle config build.nokogiri --use-system-libraries && \
    cd /app; bundle install --deployment --full-index --jobs 4 && \
    apk del build-dependencies


ADD examples/rhea-rails/. /app
ADD rhea.yml /app/config/
RUN chown -R nobody:nogroup /app
USER nobody

EXPOSE 3000

ENV KUBE_API_URL "http://localhost:8080/api/"

WORKDIR /app
CMD ["bundle", "exec", "rails", "server", "--binding=0.0.0.0"]
