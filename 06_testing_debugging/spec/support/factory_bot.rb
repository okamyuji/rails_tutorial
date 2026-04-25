# frozen_string_literal: true

# FactoryBotのサポート設定
# spec/support/factory_bot.rb

RSpec.configure { |config| config.include FactoryBot::Syntax::Methods }
