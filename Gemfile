source 'https://rubygems.org'

# 下記のコードは、gemに:githubオプション(githubのリポジトリからgemを
# ダウンロードするオプション)がついている場合に、HTTPSプロトコルで
# githubからgemを取得するためのもの。githubオプションはデフォルトで
# gitプロトコルで通信するためセキュアでなく、bundler1.13以降だと警告
# がでる。
# git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'rails',                   '5.1.6'
gem 'bcrypt',                  '3.1.12'
gem 'faker',                   '1.7.3'
gem 'carrierwave',             '1.2.2' # 画像アップローダ
gem 'carrierwave-data-uri'
gem 'mini_magick',             '4.7.0' # 画像をリサイズしたりする
gem 'will_paginate',           '3.1.6'
gem 'bootstrap-will_paginate', '1.0.0'
gem 'bootstrap-sass',          '3.4.1'
gem 'puma',                    '3.9.1'
gem 'sass-rails',              '5.0.6'
gem 'uglifier',                '3.2.0'
gem 'coffee-rails',            '4.2.2'
gem 'jquery-rails',            '4.3.1'
gem 'turbolinks',              '5.0.1'
gem 'jbuilder',                '2.7.0'
gem 'config',                  '1.7.1'
gem 'ransack'

# 開発環境とテスト環境のみで使用するgem
group :development, :test do
  gem 'sqlite3', '1.3.13'

  # ↓のplatformオプションが必要な理由は謎
  gem 'byebug',  '9.0.6', platform: :mri

  # rspec関連
  gem 'rspec-rails', '~>3.8.0'
  gem 'factory_bot_rails', '~> 4.10.0'

  # N+1クエリ問題用
  gem 'bullet'

  # rails consoleでデータを見やすくする
  gem 'hirb'
  gem 'hirb-unicode'
end

# 開発環境のみで使用するgem
group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.1.5'
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'

  # rspec関連
  gem 'spring-commands-rspec'

  # erd関連
  gem 'rails-erd'
end

# テスト環境のみで使用するgem
group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest',                 '5.10.3'
  gem 'minitest-reporters',       '1.1.14'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'

  # rspec関連
  gem 'guard-rspec', require: false
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'

  # Capybara関連
  gem 'capybara',              '~> 2.15.2' 
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

# 本番環境のみで使用するgem
group :production do
  gem 'pg', '0.20.0'

  # 様々なクラウドサービスからRubyを利用しやすくするためのライブラリ
  gem 'fog', '1.42'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# 2周目以降追加gem
gem 'slim-rails'
gem 'html2slim'
gem 'high_voltage'
