# frozen_string_literal: true

# コメントモデルのテスト
# spec/models/comment_spec.rb

require "rails_helper"

RSpec.describe Comment, type: :model do
  # 関連付けのテスト
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:article) }
  end

  # バリデーションのテスト
  describe "validations" do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(1).is_at_most(1000) }
  end

  # スコープのテスト
  describe "scopes" do
    let!(:recent_comment) { create(:comment, created_at: 1.hour.ago) }
    let!(:old_comment) { create(:comment, created_at: 1.week.ago) }

    describe ".recent" do
      it "returns comments ordered by created_at desc" do
        expect(Comment.recent.first).to eq(recent_comment)
        expect(Comment.recent.last).to eq(old_comment)
      end
    end
  end

  # ファクトリのテスト
  describe "factory" do
    it "has a valid factory" do
      expect(build(:comment)).to be_valid
    end

    it "has a valid factory on published article" do
      comment = build(:comment, :on_published_article)
      expect(comment).to be_valid
      expect(comment.article.published).to be true
    end
  end

  # インスタンスメソッドのテスト
  describe "#author_name" do
    let(:user) { create(:user, name: "John Doe") }
    let(:comment) { create(:comment, user: user) }

    it "returns the user name" do
      expect(comment.author_name).to eq("John Doe")
    end
  end

  describe "#truncated_content" do
    context "with short content" do
      let(:comment) { build(:comment, content: "Short") }

      it "returns the full content" do
        expect(comment.truncated_content).to eq("Short")
      end
    end

    context "with long content" do
      let(:comment) { build(:comment, content: "a" * 200) }

      it "returns truncated content" do
        expect(comment.truncated_content(length: 100).length).to be <= 103
      end
    end
  end
end
