FROM ruby:3.3

COPY . /src

WORKDIR /src

RUN bundle install

EXPOSE 4000

ENTRYPOINT ["bundle", "exec", "jekyll", "serve"]

CMD ["--host", "0.0.0.0"]
