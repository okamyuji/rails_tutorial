# frozen_string_literal: true

# Bulletの設定例
# 開発時は警告表示、テスト時は例外発生（CIで自動失敗）の二段構えにする。

# ============================================================
# 開発環境: 警告のみ
# config/environments/development.rb
# ============================================================
Rails.application.configure do
  config.after_initialize do
    Bullet.enable = true

    # 通知方法
    Bullet.alert = true # JavaScriptアラート
    Bullet.bullet_logger = true # log/bullet.log
    Bullet.console = true # ブラウザコンソール
    Bullet.rails_logger = true # Railsログ
    Bullet.add_footer = true # ページフッター
    Bullet.raise = false # 開発時は例外を発生させない

    # 通知サービス（オプション）
    # Bullet.slack = {
    #   webhook_url: 'https://hooks.slack.com/services/...',
    #   channel: '#bullet-alerts',
    #   username: 'Bullet Bot'
    # }

    # 検出の設定
    Bullet.n_plus_one_query_enable = true # N+1クエリ検出
    Bullet.unused_eager_loading_enable = true # 未使用のEager Loading検出
    Bullet.counter_cache_enable = true # Counter Cache推奨

    # 特定のパターンを無視（誤検出した場合のみ）
    # Bullet.add_safelist type: :n_plus_one_query, class_name: "Article", association: :user
  end
end

# ============================================================
# テスト環境: N+1検出でテスト失敗（CIで自動ブロック）
# config/environments/test.rb
# ============================================================
# Rails.application.configure do
#   config.after_initialize do
#     Bullet.enable = true
#     Bullet.bullet_logger = true
#     Bullet.raise = true  # N+1検出時にテストを失敗させる
#   end
# end

# ============================================================
# RSpecとの統合
# spec/rails_helper.rb
# ============================================================
# RSpec.configure do |config|
#   if Bullet.enable?
#     config.before(:each) do
#       Bullet.start_request
#     end
#
#     config.after(:each) do
#       Bullet.perform_out_of_channel_notifications if Bullet.notification?
#       Bullet.end_request
#     end
#   end
# end

# ============================================================
# 代替: prosopite
# ============================================================
# bullet で誤検出が多い場合は prosopite gem への切り替えも検討できる。
# https://github.com/charkost/prosopite
