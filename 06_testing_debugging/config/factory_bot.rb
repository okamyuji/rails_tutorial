# frozen_string_literal: true

# FactoryBotの設定ファイル
# spec/support/factory_bot.rb

RSpec.configure do |config|
  # FactoryBotのメソッドを直接使用可能にする
  # create(:user) instead of FactoryBot.create(:user)
  config.include FactoryBot::Syntax::Methods

  # ファクトリの定義をリロード（開発時に便利）
  config.before(:suite) do
    FactoryBot.reload
  end

  # Lint（ファクトリの検証）
  # config.before(:suite) do
  #   FactoryBot.lint
  # end
end

# FactoryBotの設定
FactoryBot.define do
  # シーケンスのリセット
  to_create(&:save!)

  # トレイトの継承設定
  # trait_for_all_factories do
  #   after(:build) do |object|
  #     # すべてのファクトリに適用される処理
  #   end
  # end
end

# FactoryBot設定オプション
# FactoryBot.use_parent_strategy = true  # 親の戦略を使用
# FactoryBot.allow_class_lookup = true   # クラス名からファクトリを検索

# カスタム戦略の定義例
# class JsonStrategy
#   def initialize
#     @strategy = FactoryBot.strategy_by_name(:create).new
#   end
#
#   delegate :association, to: :@strategy
#
#   def result(evaluation)
#     @strategy.result(evaluation).to_json
#   end
# end
#
# FactoryBot.register_strategy(:json, JsonStrategy)

