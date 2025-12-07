# 第7章：デプロイと運用

## 7.1 本番環境への移行準備

### 環境変数と秘密情報の安全な管理

本番環境では、秘密情報をコードに直接書いてはいけません。環境変数を使用して管理します。

Railsは、`credentials`機能を提供します。

```bash
rails credentials:edit
```

これにより、暗号化されたファイルが開きます。

```yaml
secret_key_base: your-secret-key
database:
  password: your-database-password
aws:
  access_key_id: your-access-key
  secret_access_key: your-secret-key
```

コードから参照します。

```ruby
Rails.application.credentials.database[:password]
Rails.application.credentials.aws[:access_key_id]
```

マスターキーは、`config/master.key`に保存されます。このファイルは、gitignoreに追加されているため、リポジトリにコミットされません。

本番サーバーでは、マスターキーを環境変数で渡します。

```bash
RAILS_MASTER_KEY=your-master-key rails server -e production
```

環境ごとに異なるcredentialsを使用する場合は、環境別のファイルを作成します。

```bash
rails credentials:edit --environment production
```

dotenv-railsを使用する方法もあります。

```ruby
# Gemfile
gem 'dotenv-rails', groups: [:development, :test]
```

`.env`ファイルに環境変数を記述します。

```text
DATABASE_URL=postgres://localhost/myapp
SECRET_KEY_BASE=your-secret-key
```

このファイルも、gitignoreに追加します。コードから環境変数を参照します。

```ruby
ENV['DATABASE_URL']
ENV['SECRET_KEY_BASE']
```

本番環境では、環境変数をサーバーで設定します。Herokuの場合は、以下のコマンドです。

```bash
heroku config:set SECRET_KEY_BASE=your-secret-key
```

### データベースマイグレーションの本番運用

本番環境でのマイグレーションは、慎重に実行すべきです。ダウンタイムを最小化する戦略が必要です。

ゼロダウンタイムマイグレーションの原則を以下に示します。

カラム追加は、安全です。既存のデータに影響しません。

```ruby
class AddAgeToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :age, :integer
  end
end
```

カラム削除は、2段階で実行します。まずコードから参照を削除し、次のデプロイでカラムを削除します。

```ruby
# 第1段階：コードから参照を削除してデプロイ
# 第2段階：カラムを削除
class RemoveAgeFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :age, :integer
  end
end
```

カラム名変更も、2段階で実行します。新しいカラムを追加し、データをコピーしてから古いカラムを削除します。

```ruby
# 第1段階：新しいカラムを追加
class AddFullNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :full_name, :string
  end
end

# 第2段階：データをコピー
class CopyNameToFullName < ActiveRecord::Migration[7.2]
  def up
    User.find_each do |user|
      user.update_column(:full_name, user.name)
    end
  end
  
  def down
    # ロールバック処理
  end
end

# 第3段階：古いカラムを削除
class RemoveNameFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :name, :string
  end
end
```

インデックス追加は、本番データが大きい場合に時間がかかります。PostgreSQLでは、`CONCURRENTLY`オプションを使用します。

```ruby
class AddIndexToUsersEmail < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!
  
  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

マイグレーションの実行前に、データベースのバックアップを取ります。

```bash
# PostgreSQL
pg_dump -U username dbname > backup.sql

# MySQL
mysqldump -u username -p dbname > backup.sql
```

本番環境でマイグレーションを実行します。

```bash
RAILS_ENV=production rails db:migrate
```

### アセットパイプラインとCDNの設定

本番環境では、アセットをプリコンパイルします。

```bash
RAILS_ENV=production rails assets:precompile
```

これにより、JavaScriptとCSSが最適化され、`public/assets`に出力されます。

`config/environments/production.rb`でアセット設定を確認します。

```ruby
config.assets.compile = false
config.assets.digest = true
```

`compile = false`は、本番環境でアセットを動的にコンパイルしないことを意味します。パフォーマンスが向上します。

`digest = true`は、ファイル名にハッシュを追加します。ブラウザキャッシュを適切に管理できます。

CDNを使用する場合は、`asset_host`を設定します。

```ruby
config.asset_host = 'https://cdn.example.com'
```

CloudfrontやFastlyなどのCDNにアセットを配置することで、配信速度が向上します。

Active Storageを使用している場合、ファイルの保存先を設定します。

```ruby
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: your-bucket-name
```

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon
```

## 7.2 継続的インテグレーションとデプロイ

### GitHub Actionsでテストを自動化する

GitHub Actionsは、CIパイプラインを構築できます。

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
      
      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Install dependencies
        run: |
          bundle install
          yarn install
      
      - name: Setup database
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
      
      - name: Run tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: bundle exec rspec
      
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage
          path: coverage/
```

このワークフローは、プッシュとプルリクエストでテストを自動実行します。

Rubocopで静的解析も実行できます。

```yaml
- name: Run Rubocop
  run: bundle exec rubocop
```

### Herokuへのデプロイ手順

Herokuは、Railsアプリケーションを簡単にデプロイできるPaaSです。

Heroku CLIをインストールします。

```bash
brew install heroku/brew/heroku
heroku login
```

アプリケーションを作成します。

```bash
heroku create your-app-name
```

データベースを追加します。

```bash
heroku addons:create heroku-postgresql:mini
```

環境変数を設定します。

```bash
heroku config:set RAILS_MASTER_KEY=your-master-key
```

デプロイします。

```bash
git push heroku main
```

マイグレーションを実行します。

```bash
heroku run rails db:migrate
```

ログを確認します。

```bash
heroku logs --tail
```

スケールアップする場合は、dynos数を増やします。

```bash
heroku ps:scale web=2
```

カスタムドメインを設定できます。

```bash
heroku domains:add www.example.com
```

### Dockerコンテナ化とKubernetesへのデプロイ

Dockerfileを作成します。

```dockerfile
FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN RAILS_ENV=production bundle exec rails assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

docker-compose.ymlでローカル環境を定義します。

```yaml
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
```

イメージをビルドして起動します。

```bash
docker-compose build
docker-compose up
```

Kubernetesにデプロイする場合は、マニフェストファイルを作成します。

```yaml
# k8s/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rails-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rails-app
  template:
    metadata:
      labels:
        app: rails-app
    spec:
      containers:
      - name: rails
        image: your-registry/rails-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: rails-secrets
              key: database-url
        - name: RAILS_MASTER_KEY
          valueFrom:
            secretKeyRef:
              name: rails-secrets
              key: master-key
```

```yaml
# k8s/service.yml
apiVersion: v1
kind: Service
metadata:
  name: rails-app
spec:
  selector:
    app: rails-app
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

デプロイします。

```bash
kubectl apply -f k8s/
```

## 7.3 監視とログ管理

### Railsログの活用と構造化

Railsは、デフォルトで`log/`ディレクトリにログを出力します。ログレベルを設定できます。

```ruby
# config/environments/production.rb
config.log_level = :info
```

ログレベルは、debug、info、warn、error、fatalがあります。本番環境では、infoまたはwarn以上に設定します。

構造化ログを使用すると、解析が容易になります。

```ruby
# Gemfile
gem 'lograge'
```

```ruby
# config/environments/production.rb
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new
```

これにより、ログがJSON形式で出力されます。

```json
{"method":"GET","path":"/articles","status":200,"duration":45.2}
```

カスタムデータをログに追加できます。

```ruby
config.lograge.custom_options = lambda do |event|
  {
    user_id: event.payload[:user_id],
    ip: event.payload[:ip]
  }
end
```

### SentryやRollbarでエラーを追跡

Sentryは、エラーをリアルタイムで追跡します。

```ruby
# Gemfile
gem 'sentry-ruby'
gem 'sentry-rails'
```

```ruby
# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
end
```

エラーが発生すると、自動的にSentryに送信されます。スタックトレース、リクエスト情報、ユーザー情報が含まれます。

手動でエラーを送信することもできます。

```ruby
begin
  risky_operation
rescue => e
  Sentry.capture_exception(e)
  raise
end
```

### 本番環境のパフォーマンス監視

New RelicやDatadogは、アプリケーションのパフォーマンスを監視します。

```ruby
# Gemfile
gem 'newrelic_rpm'
```

```yaml
# config/newrelic.yml
production:
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: My Rails App
```

New Relicは、以下の情報を提供します。

レスポンスタイム、スループット、エラーレートなどのメトリクス。

遅いトランザクションの特定。データベースクエリ、外部API呼び出しの詳細。

リアルユーザーモニタリング（RUM）。実際のユーザーのページロード時間。

これらの情報により、パフォーマンスのボトルネックを特定し、最適化できます。

## まとめ

この章では、デプロイと運用について学びました。

本番環境への移行には、秘密情報の安全な管理、ゼロダウンタイムマイグレーション、アセットの最適化が必要です。credentialsや環境変数を使用して、機密情報を保護します。

継続的インテグレーションにより、コードの品質を自動的に保証します。GitHub Actionsでテストを自動化し、HerokuやDockerで簡単にデプロイできます。

監視とログ管理は、本番環境の安定性に不可欠です。構造化ログで解析を容易にし、Sentryでエラーをリアルタイムで追跡し、New Relicでパフォーマンスを監視します。

これで、Railsアプリケーションの開発から運用までの全体像を習得しました。実践を通じて、さらに深い理解を得てください。
