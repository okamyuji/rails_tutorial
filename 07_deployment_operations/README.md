# 第7章：デプロイと運用

この章では、本番環境への移行準備、継続的インテグレーション、監視とログ管理を実装します。

## 前提条件

- Ruby 3.2以上
- Rails 7.2以上
- PostgreSQL
- Docker（オプション）

## ディレクトリ構造

```text
07_deployment_operations/
├── config/                      # 設定ファイル
│   ├── credentials.rb          # 秘密情報管理
│   ├── database_production.rb  # 本番DB設定
│   ├── puma_production.rb      # Puma設定
│   └── lograge.rb              # ログ設定
├── docker/                      # Docker関連
│   ├── Dockerfile              # Dockerfile
│   ├── docker-compose.yml      # Docker Compose
│   └── .dockerignore           # Docker除外設定
├── kubernetes/                  # Kubernetes関連
│   ├── deployment.yml          # デプロイメント
│   ├── service.yml             # サービス
│   └── configmap.yml           # 設定マップ
├── github_actions/              # CI/CD
│   ├── ci.yml                  # CIワークフロー
│   └── deploy.yml              # デプロイワークフロー
├── monitoring/                  # 監視設定
│   ├── newrelic.rb             # New Relic設定
│   ├── sentry.rb               # Sentry設定
│   └── datadog.rb              # Datadog設定
├── deployment_demo.rb          # デプロイデモ
├── ci_cd_demo.rb               # CI/CDデモ
├── monitoring_demo.rb          # 監視デモ
├── README.md                   # このファイル
└── seed_data.rb                # サンプルデータ生成
```

## デモスクリプトの実行

```bash
# デプロイの概要デモ
rails runner deployment_demo.rb

# CI/CDの詳細デモ
rails runner ci_cd_demo.rb

# 監視・ログ管理のデモ
rails runner monitoring_demo.rb

# サンプルデータの生成
rails runner seed_data.rb
```

## 主な実装内容

### 1. 秘密情報の管理

```bash
# credentials編集
rails credentials:edit

# 環境別credentials
rails credentials:edit --environment production
```

### 2. Docker化

```dockerfile
FROM ruby:3.2
WORKDIR /app
COPY . .
RUN bundle install
CMD ["rails", "server", "-b", "0.0.0.0"]
```

### 3. GitHub Actions CI

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
      - run: bundle exec rspec
```

### 4. 監視とログ

```ruby
# Sentry
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
end

# Lograge
config.lograge.enabled = true
```

## デプロイ先

- Heroku
- AWS (ECS, EKS)
- Google Cloud (Cloud Run, GKE)
- DigitalOcean (App Platform)

## ベストプラクティス

### セキュリティ

1. **秘密情報** - 環境変数またはcredentialsを使用
2. **HTTPS** - 本番環境では必須
3. **CSP** - Content Security Policyを設定

### パフォーマンス

1. **CDN** - 静的アセットをCDNで配信
2. **キャッシュ** - Redisでキャッシュ
3. **バックグラウンドジョブ** - Sidekiqを使用

### 監視

1. **エラー追跡** - Sentry/Rollbar
2. **APM** - New Relic/Datadog
3. **ログ** - 構造化ログ（Lograge）

## 次のステップ

1. 環境変数を設定
2. Dockerイメージをビルド
3. CI/CDパイプラインを構築
4. 監視を設定
