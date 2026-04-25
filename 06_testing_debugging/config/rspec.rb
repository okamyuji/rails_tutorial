# frozen_string_literal: true

# RSpecの設定ファイル
# .rspec

# --require spec_helper
# --format documentation
# --color
# --order random

# spec/spec_helper.rb の設定例
RSpec.configure do |config|
  # 期待値の構文設定
  config.expect_with :rspec do |expectations|
    # チェーン句をカスタムマッチャーの説明に含める
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # モックの設定
  config.mock_with :rspec do |mocks|
    # 部分的なダブルの検証を有効化
    mocks.verify_partial_doubles = true
  end

  # 共有コンテキストのメタデータ動作
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # フォーカスフィルタリング
  # `focus: true`が付いたテストのみ実行
  config.filter_run_when_matching :focus

  # 失敗例の詳細出力
  config.example_status_persistence_file_path = "spec/examples.txt"

  # `--only-failures`オプションを有効化
  config.filter_run_when_matching :focus

  # 単一ファイル実行時のフォーマット
  config.default_formatter = "doc" if config.files_to_run.one?

  # プロファイリング（遅いテストの特定）
  config.profile_examples = 10

  # ランダム実行
  config.order = :random

  # シード値の設定（再現性のため）
  Kernel.srand config.seed

  # before/afterフック
  config.before(:suite) do
    # テストスイート開始前の処理
  end

  config.after(:suite) do
    # テストスイート終了後の処理
  end

  # 各テスト前後のフック
  config.before(:each) do
    # 各テスト前の処理
  end

  config.after(:each) do
    # 各テスト後の処理
  end

  # 特定のタイプに対するフック
  config.before(:each, type: :controller) do
    # コントローラテスト前の処理
  end

  # トランザクション設定
  config.use_transactional_fixtures = true

  # ファイル位置からテストタイプを推測
  config.infer_spec_type_from_file_location!

  # バックトレースからRailsのフレームを除外
  config.filter_rails_from_backtrace!
end
