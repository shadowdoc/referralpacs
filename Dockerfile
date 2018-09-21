FROM ruby:1.9-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs mysql-client libmysqlclient-dev imagemagick

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir /ref
ADD . /ref
WORKDIR /ref