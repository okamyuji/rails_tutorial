# frozen_string_literal: true

# SimpleCovの設定ファイル
# spec/spec_helper.rb の先頭で require する

require 'simplecov'

SimpleCov.start 'rails' do
  # カバレッジから除外するディレクトリ
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'

  # カバレッジグループの定義
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Views', 'app/views'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Jobs', 'app/jobs'
  add_group 'Services', 'app/services'
  add_group 'Policies', 'app/policies'
  add_group 'Serializers', 'app/serializers'

  # 最小カバレッジの設定（オプション）
  # minimum_coverage 80
  # minimum_coverage_by_file 70

  # カバレッジが低下した場合に失敗させる
  # refuse_coverage_drop

  # マージ設定（並列テスト用）
  enable_coverage :branch

  # 出力フォーマット
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter
    # SimpleCov::Formatter::JSONFormatter,
    # SimpleCov::Formatter::LcovFormatter
  ])

  # カバレッジ結果のマージ
  use_merging true
  merge_timeout 3600

  # 追跡するファイル
  track_files '{app,lib}/**/*.rb'
end

# CI環境での設定
if ENV['CI']
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

# カバレッジレポートの設定
SimpleCov.at_exit do
  SimpleCov.result.format!

  # カバレッジが閾値を下回った場合に警告
  if SimpleCov.result.covered_percent < 80
    puts "Coverage is below 80%: #{SimpleCov.result.covered_percent.round(2)}%"
  end
end

