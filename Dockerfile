FROM ruby:3.3-bullseye

LABEL maintainer="weijianduan0302@gmail.com"

COPY . /src

WORKDIR /src

RUN bundle install

EXPOSE 4000

ENTRYPOINT ["bundle", "exec", "jekyll", "serve"]

CMD ["--host", "0.0.0.0"]
