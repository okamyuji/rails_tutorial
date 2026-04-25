# 自動化ツール群のGemfileスニペット
# 既存のGemfileの :development, :test グループに追記して使う想定です。

group :development, :test do
  # 静的解析・フォーマット
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "syntax_tree", require: false # コマンド名は stree
  gem "erb_lint", require: false # コマンド名は erblint

  # 型検査
  gem "sorbet-static-and-runtime", require: false
  gem "tapioca", require: false

  # セキュリティ
  gem "brakeman", require: false
  gem "bundler-audit", require: false

  # マイグレーション安全性
  gem "strong_migrations"
end

group :development do
  gem "bullet" # development/test両方で有効化したい場合は上のグループへ
end

group :test do
  gem "simplecov", require: false
end
