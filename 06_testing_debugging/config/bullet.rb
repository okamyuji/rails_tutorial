# frozen_string_literal: true

# Bulletの設定ファイル
# config/environments/development.rb に追加

# config.after_initialize do
#   Bullet.enable = true
#   Bullet.alert = true
#   Bullet.bullet_logger = true
#   Bullet.console = true
#   Bullet.rails_logger = true
#   Bullet.add_footer = true
# end

# 詳細な設定例
Rails.application.configure do
  config.after_initialize do
    Bullet.enable = true

    # 通知方法
    Bullet.alert = true                    # JavaScriptアラート
    Bullet.bullet_logger = true            # log/bullet.log
    Bullet.console = true                  # ブラウザコンソール
    Bullet.rails_logger = true             # Railsログ
    Bullet.add_footer = true               # ページフッター
    Bullet.raise = false                   # 例外を発生させる（CI用）

    # 通知サービス（オプション）
    # Bullet.slack = {
    #   webhook_url: 'https://hooks.slack.com/services/...',
    #   channel: '#bullet-alerts',
    #   username: 'Bullet Bot'
    # }

    # Bullet.honeybadger = true
    # Bullet.bugsnag = true
    # Bullet.airbrake = true
    # Bullet.rollbar = true
    # Bullet.sentry = true

    # 検出の設定
    Bullet.n_plus_one_query_enable = true  # N+1クエリ検出
    Bullet.unused_eager_loading_enable = true  # 未使用のEager Loading検出
    Bullet.counter_cache_enable = true     # Counter Cache推奨

    # 特定のパターンを無視
    # Bullet.add_safelist type: :n_plus_one_query, class_name: "Article", association: :user
    # Bullet.add_safelist type: :unused_eager_loading, class_name: "Article", association: :comments
    # Bullet.add_safelist type: :counter_cache, class_name: "Article", association: :comments

    # スタックトレースの行数
    Bullet.stacktrace_includes = []
    Bullet.stacktrace_excludes = []

    # スキップするパス
    Bullet.skip_html_injection = false
  end
end

# テスト環境での設定
# config/environments/test.rb
# Rails.application.configure do
#   config.after_initialize do
#     Bullet.enable = true
#     Bullet.bullet_logger = true
#     Bullet.raise = true  # N+1があればテスト失敗
#   end
# end

# RSpecとの統合
# spec/rails_helper.rb
# if Bullet.enable?
#   config.before(:each) do
#     Bullet.start_request
#   end
#
#   config.after(:each) do
#     Bullet.perform_out_of_channel_notifications if Bullet.notification?
#     Bullet.end_request
#   end
# end

