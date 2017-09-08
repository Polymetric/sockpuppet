FROM ruby:2.4.1

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN cd /app && bundle install

ADD . /app

RUN chown -R nobody:nogroup /app
USER nobody

ENV RACK_ENV production
WORKDIR /app

CMD bundle exec ./bot.rb
