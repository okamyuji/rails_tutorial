require "test_helper"

class SeedsTest < ActiveSupport::TestCase
  test "db/seeds.rb creates sample comments and is idempotent" do
    Rails.application.load_seed
    first = [ Article.count, Comment.count ]

    Rails.application.load_seed

    assert_equal first, [ Article.count, Comment.count ]
    assert Comment.exists?(content: "記事1へのコメント1です。")
  end
end
