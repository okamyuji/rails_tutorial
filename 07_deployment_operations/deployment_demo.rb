# frozen_string_literal: true

# デプロイと運用の概要デモンストレーション
# rails runner deployment_demo.rb で実行します

puts '=' * 80
puts 'デプロイと運用の概要デモンストレーション'
puts '=' * 80
puts ''

puts '1. 秘密情報の管理'
puts '-' * 40
puts ''

credentials_info = <<~TEXT
■ Rails Credentials

# credentialsの編集
rails credentials:edit

# 環境別のcredentials
rails credentials:edit --environment production

# credentials.yml.enc の内容例
secret_key_base: your-secret-key
database:
  password: your-database-password
aws:
  access_key_id: your-access-key
  secret_access_key: your-secret-key

# コードからの参照
Rails.application.credentials.database[:password]
Rails.application.credentials.dig(:aws, :access_key_id)

# マスターキーの設定（本番環境）
RAILS_MASTER_KEY=your-master-key rails server -e production
TEXT

puts credentials_info
puts ''

puts '■ 環境変数（dotenv）:'
puts ''

dotenv_info = <<~RUBY
# Gemfile
gem 'dotenv-rails', groups: [:development, :test]

# .env ファイル
DATABASE_URL=postgres://localhost/myapp
SECRET_KEY_BASE=your-secret-key
REDIS_URL=redis://localhost:6379

# コードからの参照
ENV['DATABASE_URL']
ENV.fetch('SECRET_KEY_BASE')
RUBY

puts dotenv_info
puts ''

puts '2. データベースマイグレーションの本番運用'
puts '-' * 40
puts ''

migration_info = <<~TEXT
■ ゼロダウンタイムマイグレーションの原則

1. カラム追加 → 安全
2. カラム削除 → 2段階で実行
   - 第1段階: コードから参照を削除
   - 第2段階: カラムを削除
3. カラム名変更 → 新カラム追加 → データコピー → 旧カラム削除

■ インデックスの追加（PostgreSQL）

class AddIndexToUsersEmail < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  
  def change
    add_index :users, :email, algorithm: :concurrently
  end
end

■ マイグレーション前のバックアップ

# PostgreSQL
pg_dump -U username dbname > backup.sql

# MySQL
mysqldump -u username -p dbname > backup.sql

■ 本番環境でのマイグレーション

RAILS_ENV=production rails db:migrate
TEXT

puts migration_info
puts ''

puts '3. アセットパイプラインとCDN'
puts '-' * 40
puts ''

assets_info = <<~RUBY
# アセットのプリコンパイル
RAILS_ENV=production rails assets:precompile

# config/environments/production.rb
config.assets.compile = false
config.assets.digest = true

# CDNの設定
config.asset_host = 'https://cdn.example.com'

# Active Storageの設定（S3）
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: your-bucket-name

# config/environments/production.rb
config.active_storage.service = :amazon
RUBY

puts assets_info
puts ''

puts '4. Herokuへのデプロイ'
puts '-' * 40
puts ''

heroku_info = <<~BASH
# Heroku CLIのインストール
brew install heroku/brew/heroku
heroku login

# アプリケーションの作成
heroku create your-app-name

# データベースの追加
heroku addons:create heroku-postgresql:mini

# 環境変数の設定
heroku config:set RAILS_MASTER_KEY=your-master-key

# デプロイ
git push heroku main

# マイグレーション
heroku run rails db:migrate

# ログの確認
heroku logs --tail

# スケールアップ
heroku ps:scale web=2

# カスタムドメイン
heroku domains:add www.example.com
BASH

puts heroku_info
puts ''

puts '5. Dockerコンテナ化'
puts '-' * 40
puts ''

docker_info = <<~TEXT
■ Dockerfile

FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN RAILS_ENV=production bundle exec rails assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

■ docker-compose.yml

version: '3.8'

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  web:
    build: .
    command: bundle exec rails s -b 0.0.0.0
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://postgres:postgres@db:5432/app_development

volumes:
  postgres_data:

■ コマンド

docker-compose build
docker-compose up
docker-compose run web rails db:create db:migrate
TEXT

puts docker_info
puts ''

puts '=' * 80
puts '本番環境チェックリスト'
puts '=' * 80
puts ''

puts '□ 秘密情報が環境変数/credentialsで管理されている'
puts '□ HTTPSが有効化されている'
puts '□ データベースのバックアップが設定されている'
puts '□ アセットがプリコンパイルされている'
puts '□ ログレベルが適切に設定されている'
puts '□ エラー追跡サービスが設定されている'
puts '□ パフォーマンス監視が設定されている'
puts ''

puts '=' * 80

