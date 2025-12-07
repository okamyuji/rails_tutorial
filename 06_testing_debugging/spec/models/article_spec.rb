# frozen_string_literal: true

# 記事モデルのテスト
# spec/models/article_spec.rb

require 'rails_helper'

RSpec.describe Article, type: :model do
  # 関連付けのテスト
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  # バリデーションのテスト
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
  end

  # スコープのテスト
  describe 'scopes' do
    let!(:published_article) { create(:article, :published) }
    let!(:draft_article) { create(:article, published: false) }
    let!(:featured_article) { create(:article, :featured) }
    let!(:old_article) { create(:article, :published, created_at: 1.month.ago) }

    describe '.published' do
      it 'returns only published articles' do
        expect(Article.published).to include(published_article, featured_article)
        expect(Article.published).not_to include(draft_article)
      end
    end

    describe '.draft' do
      it 'returns only draft articles' do
        expect(Article.draft).to include(draft_article)
        expect(Article.draft).not_to include(published_article)
      end
    end

    describe '.featured' do
      it 'returns only featured articles' do
        expect(Article.featured).to include(featured_article)
        expect(Article.featured).not_to include(published_article, draft_article)
      end
    end

    describe '.recent' do
      it 'returns articles ordered by created_at desc' do
        expect(Article.recent.first).to eq(draft_article)
        expect(Article.recent.last).to eq(old_article)
      end
    end
  end

  # インスタンスメソッドのテスト
  describe '#publish!' do
    let(:article) { create(:article, published: false) }

    it 'sets published to true' do
      article.publish!
      expect(article.published).to be true
    end

    it 'sets published_at to current time' do
      freeze_time do
        article.publish!
        expect(article.published_at).to eq(Time.current)
      end
    end
  end

  describe '#unpublish!' do
    let(:article) { create(:article, :published) }

    it 'sets published to false' do
      article.unpublish!
      expect(article.published).to be false
    end

    it 'sets published_at to nil' do
      article.unpublish!
      expect(article.published_at).to be_nil
    end
  end

  describe '#draft?' do
    context 'when article is not published' do
      let(:article) { build(:article, published: false) }

      it 'returns true' do
        expect(article.draft?).to be true
      end
    end

    context 'when article is published' do
      let(:article) { build(:article, :published) }

      it 'returns false' do
        expect(article.draft?).to be false
      end
    end
  end

  describe '#reading_time' do
    context 'with short content' do
      let(:article) { build(:article, content: 'Short content') }

      it 'returns 1 minute' do
        expect(article.reading_time).to eq(1)
      end
    end

    context 'with long content' do
      let(:article) { build(:article, content: 'word ' * 500) }

      it 'returns estimated reading time' do
        expect(article.reading_time).to be > 1
      end
    end
  end

  # コールバックのテスト
  describe 'callbacks' do
    describe 'before_save' do
      let(:article) { build(:article, title: '  Test Title  ') }

      it 'strips whitespace from title' do
        article.save
        expect(article.title).to eq('Test Title')
      end
    end
  end

  # ファクトリのテスト
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:article)).to be_valid
    end

    it 'has a valid published factory' do
      expect(build(:article, :published)).to be_valid
    end

    it 'has a valid factory with comments' do
      article = create(:article, :with_comments, comments_count: 5)
      expect(article.comments.count).to eq(5)
    end
  end
end

