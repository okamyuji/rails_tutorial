# frozen_string_literal: true

# 認証と認可の概要デモンストレーション
# rails runner auth_demo.rb で実行します

puts "=" * 80
puts "認証と認可の概要デモンストレーション"
puts "=" * 80
puts ""

puts "このデモでは、以下の機能を確認できます:"
puts "-" * 40
puts ""

puts "1. Devise（認証）:"
puts "   - ユーザー登録・ログイン・ログアウト"
puts "   - パスワードリセット"
puts "   - メールアドレス確認"
puts "   - アカウントロック"
puts "   - ログイン状態の保持"
puts ""

puts "2. OmniAuth（外部認証）:"
puts "   - Google認証"
puts "   - Facebook認証"
puts "   - GitHub認証"
puts ""

puts "3. Pundit（認可）:"
puts "   - ポリシークラスによる権限管理"
puts "   - ロールベースアクセス制御"
puts "   - リソースベースアクセス制御"
puts ""

puts "4. セッションとCookie:"
puts "   - セキュアなセッション管理"
puts "   - Cookie設定"
puts "   - CSRF対策"
puts ""

puts "=" * 80
puts "提供されているファイル"
puts "=" * 80
puts ""

puts "■ 設定ファイル:"
puts "  config/"
puts "    - devise.rb              # Devise設定"
puts "    - session_store.rb       # セッション設定"
puts "    - omniauth.rb            # OmniAuth設定"
puts ""

puts "■ コントローラ:"
puts "  controllers/"
puts "    - application_controller.rb # 認証・認可の基盤"
puts "    - users/"
puts "        - omniauth_callbacks_controller.rb"
puts "        - registrations_controller.rb"
puts "        - sessions_controller.rb"
puts ""

puts "■ モデル:"
puts "  models/"
puts "    - user.rb                # Userモデル（Devise）"
puts "    - permission.rb          # 権限モデル"
puts ""

puts "■ ポリシー:"
puts "  policies/"
puts "    - application_policy.rb  # 基底ポリシー"
puts "    - article_policy.rb      # 記事ポリシー"
puts "    - comment_policy.rb      # コメントポリシー"
puts ""

puts "■ ビュー:"
puts "  views/devise/"
puts "    - sessions/              # ログイン画面"
puts "    - registrations/         # 登録・編集画面"
puts "    - passwords/             # パスワードリセット画面"
puts "    - confirmations/         # メール確認画面"
puts "    - shared/                # 共通パーシャル"
puts ""

puts "■ デモスクリプト:"
puts "  - auth_demo.rb             # 概要デモ（このファイル）"
puts "  - devise_demo.rb           # Deviseデモ"
puts "  - omniauth_demo.rb         # OmniAuthデモ"
puts "  - pundit_demo.rb           # Punditデモ"
puts "  - session_demo.rb          # セッションデモ"
puts "  - seed_data.rb             # サンプルデータ生成"
puts ""

puts "=" * 80
puts "認証（Authentication）と認可（Authorization）の違い"
puts "=" * 80
puts ""

puts "■ 認証（Authentication）:"
puts "  「あなたは誰ですか？」を確認するプロセス"
puts "  - ユーザー名とパスワードの検証"
puts "  - 外部サービス（Google、Facebook）による認証"
puts "  - 二要素認証"
puts ""

puts "■ 認可（Authorization）:"
puts "  「あなたは何ができますか？」を確認するプロセス"
puts "  - リソースへのアクセス権限"
puts "  - 操作の許可/拒否"
puts "  - ロールベースのアクセス制御"
puts ""

puts "=" * 80
puts "セキュリティのベストプラクティス"
puts "=" * 80
puts ""

puts "1. パスワードセキュリティ:"
puts "   - 強力なパスワードポリシー（最小8文字、大文字小文字数字記号）"
puts "   - bcryptによるハッシュ化"
puts "   - パスワードの定期的な変更を促す"
puts ""

puts "2. セッションセキュリティ:"
puts "   - セッションIDの再生成（ログイン時）"
puts "   - 適切なタイムアウト設定"
puts "   - セキュアCookieの使用（HTTPS）"
puts ""

puts "3. CSRF対策:"
puts "   - CSRFトークンの検証"
puts "   - SameSite Cookie属性"
puts ""

puts "4. その他:"
puts "   - HTTPOnly Cookie（XSS対策）"
puts "   - レート制限（ブルートフォース対策）"
puts "   - アカウントロック機能"
puts ""

puts "=" * 80
puts "次のステップ"
puts "=" * 80
puts ""

puts "各デモスクリプトを実行して詳細を確認:"
puts ""
puts "  rails runner devise_demo.rb    # Deviseの詳細"
puts "  rails runner omniauth_demo.rb  # OmniAuthの詳細"
puts "  rails runner pundit_demo.rb    # Punditの詳細"
puts "  rails runner session_demo.rb   # セッション管理の詳細"
puts "  rails runner seed_data.rb      # サンプルデータ生成"
puts ""

puts "実際にアプリケーションを起動して確認:"
puts ""
puts "  1. rails server でサーバーを起動"
puts "  2. http://localhost:3000/users/sign_up でユーザー登録"
puts "  3. http://localhost:3000/users/sign_in でログイン"
puts "  4. 権限に応じた操作を確認"
puts ""

puts "=" * 80
