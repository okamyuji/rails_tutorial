# frozen_string_literal: true

# SimpleCovの設定例
# spec/spec_helper.rb の先頭で require する。
# 閾値を割ったらテスト実行自体を失敗させ、
# CIでカバレッジ低下を自動ブロックする方針です。

require "simplecov"

SimpleCov.start "rails" do
  # カバレッジから除外するディレクトリ
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  # カバレッジグループの定義
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Views", "app/views"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Jobs", "app/jobs"
  add_group "Services", "app/services"
  add_group "Policies", "app/policies"
  add_group "Serializers", "app/serializers"

  # 閾値割れで非0 exit（CI失敗）させる設定
  minimum_coverage 80
  minimum_coverage_by_file 60
  refuse_coverage_drop

  # ブランチカバレッジ
  enable_coverage :branch

  # 出力フォーマット
  formatter SimpleCov::Formatter::MultiFormatter.new(
              [
                SimpleCov::Formatter::HTMLFormatter
                # SimpleCov::Formatter::JSONFormatter,
                # SimpleCov::Formatter::LcovFormatter
              ]
            )

  # カバレッジ結果のマージ（並列テスト用）
  use_merging true
  merge_timeout 3600

  # 追跡するファイル
  track_files "{app,lib}/**/*.rb"
end

# CI環境ではCoberturaフォーマットを追加し、
# GitHub ActionsやCodecovなど外部ツールで取り込みやすくする。
if ENV["CI"]
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
