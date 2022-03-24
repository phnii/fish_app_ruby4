
FROM ruby:2.6.5

RUN curl -SL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y --no-install-recommends\
    yarn \
    mariadb-client  \
    build-essential  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



WORKDIR /fish_app_ruby

COPY Gemfile /fish_app_ruby/Gemfile
COPY Gemfile.lock /fish_app_ruby/Gemfile.lock

RUN gem install bundler
RUN bundle install

RUN yarn add jquery
RUN yarn add @nathanvda/cocoon
RUN yarn install --check-files
COPY . /fish_app_ruby


