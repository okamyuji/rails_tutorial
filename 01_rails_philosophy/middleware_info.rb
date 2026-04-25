# frozen_string_literal: true

# このスクリプトは、Railsアプリケーションのミドルウェアスタックを
# 詳細に表示します。ミドルウェアがどのような順序で実行されるかを
# 理解するために使用します。

puts "=" * 80
puts "Railsミドルウェアスタック"
puts "=" * 80
puts ""

# Railsアプリケーションのミドルウェアスタックを取得
middlewares = Rails.application.middleware.middlewares

puts "合計 #{middlewares.size} 個のミドルウェアが登録されています"
puts ""

# 各ミドルウェアを順番に表示
middlewares.each_with_index do |middleware, index|
  puts "#{index + 1}. #{middleware}"

  # 主要なミドルウェアの説明を追加
  case middleware.to_s
  when /Rack::Sendfile/
    puts "   → 静的ファイルの配信を効率化します"
  when /ActionDispatch::Static/
    puts "   → public/ディレクトリの静的ファイルを配信します"
  when /ActionDispatch::Executor/
    puts "   → リクエストごとにアプリケーションコードを再読み込みします（development）"
  when /ActionDispatch::ServerTiming/
    puts "   → サーバサイドのパフォーマンス情報をレスポンスヘッダに追加します"
  when /ActionDispatch::SSL/
    puts "   → HTTPSへのリダイレクトとHSTS設定を行います"
  when /ActionDispatch::Cookies/
    puts "   → クッキーの読み書きを行います"
  when /ActionDispatch::Session/
    puts "   → セッション管理を行います"
  when /ActionDispatch::Flash/
    puts "   → フラッシュメッセージ（一時的な通知）を管理します"
  when /ActionDispatch::ContentSecurityPolicy/
    puts "   → Content Security Policy ヘッダを設定してXSS攻撃を防ぎます"
  when /Rack::Head/
    puts "   → HEADリクエストを適切に処理します"
  when /Rack::ConditionalGet/
    puts "   → ETagとLast-Modifiedヘッダを使用したキャッシュ制御を行います"
  when /Rack::ETag/
    puts "   → レスポンスにETagヘッダを追加します"
  when /Rack::TempfileReaper/
    puts "   → リクエスト処理後に一時ファイルをクリーンアップします"
  when /ActionDispatch::RequestId/
    puts "   → 各リクエストに一意のIDを割り当てます"
  when /ActionDispatch::RemoteIp/
    puts "   → クライアントの実際のIPアドレスを特定します"
  when /Rails::Rack::Logger/
    puts "   → リクエストとレスポンスをログに記録します"
  when /ActionDispatch::ShowExceptions/
    puts "   → 例外が発生した場合にエラーページを表示します"
  when /ActionDispatch::DebugExceptions/
    puts "   → 開発環境で詳細なエラー情報を表示します"
  when /ActionDispatch::ActionableExceptions/
    puts "   → エラーページに対処法を表示します"
  when /ActionDispatch::Reloader/
    puts "   → 開発環境でコード変更時に自動リロードします"
  when /ActionDispatch::Callbacks/
    puts "   → リクエスト前後のコールバックを実行します"
  when /ActiveRecord::Migration::CheckPending/
    puts "   → 未実行のマイグレーションがあるかチェックします"
  when /ActionDispatch::HostAuthorization/
    puts "   → DNSリバインディング攻撃を防ぎます"
  when /Rack::Runtime/
    puts "   → レスポンスに処理時間を追加します"
  when /Rack::MethodOverride/
    puts "   → PUT/DELETE/PATCHリクエストをエミュレートします"
  end
  puts ""
end

puts "=" * 80
puts "ミドルウェアの実行順序"
puts "=" * 80
puts ""
puts "リクエスト時：上から順に実行されます（1 → #{middlewares.size}）"
puts "レスポンス時：逆順に実行されます（#{middlewares.size} → 1）"
puts ""
puts "この順序により、各ミドルウェアが適切なタイミングで"
puts "リクエストとレスポンスを処理できます。"
