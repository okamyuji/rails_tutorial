# frozen_string_literal: true

# セッションストアの設定
# config/initializers/session_store.rb

# 環境に応じてセッションストアを設定
Rails.application.config.session_store :cookie_store,
                                       key:
                                         "_#{Rails.application.class.module_parent_name.downcase}_session",
                                       secure: Rails.env.production?, # HTTPSでのみCookieを送信
                                       httponly: true, # JavaScriptからのアクセスを防止
                                       same_site: :lax, # クロスサイトリクエストでのCookie送信を制限
                                       expire_after: 1.week # セッションの有効期限

# 本番環境でRedisを使用する場合
# if Rails.env.production? && ENV['REDIS_URL'].present?
#   Rails.application.config.session_store :redis_store,
#     servers: [
#       {
#         url: ENV['REDIS_URL'],
#         namespace: 'session'
#       }
#     ],
#     expire_after: 1.week,
#     key: "_#{Rails.application.class.module_parent_name.downcase}_session",
#     secure: true,
#     httponly: true,
#     same_site: :lax
# end

# セッションストアの設定オプション:
#
# :cookie_store (デフォルト)
#   - セッションデータをCookieに保存
#   - サーバー側にストレージ不要
#   - 4KBのサイズ制限
#   - 暗号化されて保存
#
# :cache_store
#   - Rails.cacheに保存
#   - メモリキャッシュやRedisを使用可能
#
# :active_record_store
#   - データベースに保存
#   - rails generate active_record:session_migration が必要
#
# :redis_store
#   - Redisに保存
#   - gem 'redis-rails' が必要
#   - 大規模アプリケーション向け

# Cookie設定のオプション:
#
# key: Cookieの名前
# secure: HTTPSでのみ送信（本番環境では必須）
# httponly: JavaScriptからのアクセスを防止（XSS対策）
# same_site: クロスサイトリクエストでの送信制限（CSRF対策）
#   - :strict: 同一サイトからのリクエストのみ
#   - :lax: 安全なクロスサイトリクエストは許可
#   - :none: すべてのリクエストで送信（secureが必要）
# expire_after: セッションの有効期限
# domain: Cookieのドメイン
# path: Cookieのパス
