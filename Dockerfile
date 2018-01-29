# https://docs.docker.com/engine/reference/builder/

FROM ruby:alpine

COPY Gemfile .
COPY Gemfile.lock .
COPY eleanorscoolapp.rb .

ENV RACK_ENV production

RUN apk -U add g++ musl-dev make

RUN bundle install

EXPOSE 3000

ENV PORT 3000

ENTRYPOINT ["ruby"]
CMD ["eleanorscoolapp.rb"]
