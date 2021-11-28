FROM ruby:alpine

# Native extensions のビルドに必要なパッケージ達
RUN apk add make gcc g++ musl-dev openssl-dev

# Jekyll 実行環境
RUN mkdir /jekyll
WORKDIR /jekyll
ADD ./Gemfile ./Gemfile.lock ./
RUN bundler install

# 作業ディレクトリ準備
RUN mkdir /work
WORKDIR /work