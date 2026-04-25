# frozen_string_literal: true

# Rails Credentialsの設定と使用方法
# config/credentials.yml.enc の管理

# ============================================================
# Credentialsの編集
# ============================================================
#
# # デフォルトのcredentialsを編集
# rails credentials:edit
#
# # 環境別のcredentialsを編集
# rails credentials:edit --environment production
# rails credentials:edit --environment staging
#
# # エディタを指定
# EDITOR="code --wait" rails credentials:edit

# ============================================================
# credentials.yml.enc の内容例
# ============================================================
#
# secret_key_base: your-very-long-secret-key-base
#
# database:
#   host: your-database-host
#   username: your-database-username
#   password: your-database-password
#
# aws:
#   access_key_id: your-aws-access-key-id
#   secret_access_key: your-aws-secret-access-key
#   region: us-east-1
#   bucket: your-s3-bucket
#
# google:
#   client_id: your-google-client-id
#   client_secret: your-google-client-secret
#
# stripe:
#   publishable_key: pk_live_xxx
#   secret_key: sk_live_xxx
#
# sendgrid:
#   api_key: your-sendgrid-api-key
#
# sentry:
#   dsn: https://xxx@sentry.io/xxx
#
# redis:
#   url: redis://localhost:6379

# ============================================================
# コードからの参照方法
# ============================================================

# 基本的な参照
# Rails.application.credentials.secret_key_base

# ネストした値の参照
# Rails.application.credentials.database[:password]
# Rails.application.credentials.dig(:database, :password)

# 環境別のcredentialsを参照
# Rails.application.credentials.dig(:production, :database, :password)

# デフォルト値を指定
# Rails.application.credentials.dig(:optional_key) || 'default_value'

# ============================================================
# 設定ファイルでの使用例
# ============================================================

# config/database.yml
# production:
#   adapter: postgresql
#   host: <%= Rails.application.credentials.dig(:database, :host) %>
#   username: <%= Rails.application.credentials.dig(:database, :username) %>
#   password: <%= Rails.application.credentials.dig(:database, :password) %>

# config/environments/production.rb
# config.action_mailer.smtp_settings = {
#   user_name: Rails.application.credentials.dig(:sendgrid, :username),
#   password: Rails.application.credentials.dig(:sendgrid, :api_key)
# }

# config/initializers/aws.rb
# Aws.config.update(
#   credentials: Aws::Credentials.new(
#     Rails.application.credentials.dig(:aws, :access_key_id),
#     Rails.application.credentials.dig(:aws, :secret_access_key)
#   ),
#   region: Rails.application.credentials.dig(:aws, :region)
# )

# ============================================================
# 本番環境でのマスターキー設定
# ============================================================

# 環境変数で設定
# RAILS_MASTER_KEY=your-master-key rails server -e production

# Heroku
# heroku config:set RAILS_MASTER_KEY=your-master-key

# Docker
# docker run -e RAILS_MASTER_KEY=your-master-key your-image

# Kubernetes Secret
# kubectl create secret generic rails-secrets \
#   --from-literal=master-key=your-master-key

# ============================================================
# セキュリティのベストプラクティス
# ============================================================

# 1. master.key は絶対にGitにコミットしない
#    - .gitignore に含まれていることを確認

# 2. 環境別のcredentialsを使用
#    - 開発/ステージング/本番で異なるキーを使用

# 3. 定期的なローテーション
#    - 定期的にキーを更新する

# 4. アクセス制限
#    - master.keyへのアクセスを最小限に
