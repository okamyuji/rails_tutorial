# 第7章：デプロイと運用

Rails実践チュートリアルの第7章サンプルアプリケーションです。第2章のActiveRecordアプリに、第3章〜第6章の機能を統合し、本番運用に必要なCI/CD・監視・デプロイ設定を追加しています。

## 構成

### アプリケーション

- 記事のCRUD（Articles）とネストされたコメント（Comments）
- ErrorHandler Concernによる統一エラーハンドリング
- NotificationJob（Solid Queue）による非同期通知
- Lograge / Sentry / New Relicによる本番監視

### CI/CD

- `.github/workflows/ci.yml` : GitHub Actionsで並列ジョブ（lint / security / secrets / test）
- `.pre-commit-config.yaml` : gitleaks, rubocop, stree, erblint, brakemanのローカルフック

### デプロイ

- `Dockerfile` : マルチステージビルドの本番用コンテナ
- `config/deploy.yml` : Kamalデプロイ設定（proxy/healthcheck, proxy/ssl）
- `.kamal/secrets` : シークレットテンプレート

### 監視

- `config/environments/production.rb` : Lograge（JSON構造化ログ）
- `config/initializers/sentry.rb` : Sentryエラー追跡
- `config/newrelic.yml` : New Relic APM
- `config/solid_queue.yml` : Solid Queueディスパッチャ/ワーカー設定

## セットアップ

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server
```

ブラウザで http://localhost:3000 を開いてください。

## 静的解析・セキュリティチェック

```bash
bundle exec rubocop --parallel
bundle exec stree check $(find . -name '*.rb' -o -name '*.rake' | grep -v vendor/) Gemfile
bundle exec erblint --lint-all
bundle exec brakeman --no-pager --exit-on-warn
bundle exec bundler-audit check --update
```

## テスト

```bash
bin/rails test
```

## Dockerでの起動

```bash
docker build -t blog_app .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=$(cat config/master.key) blog_app
```

## Kamalデプロイ

`config/deploy.yml` のサーバーアドレスとレジストリ設定を環境に合わせて変更してください。

```bash
kamal setup    # 初回
kamal deploy   # 2回目以降
```

## 動作確認コマンド

```bash
bundle exec rubocop --version
bundle exec brakeman --version
bin/rails server
```
