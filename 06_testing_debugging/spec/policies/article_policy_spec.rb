require 'rails_helper'

RSpec.describe ArticlePolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }
  let(:article) { create(:article, user: user) }
  let(:published_article) { create(:article, :published, user: user) }

  describe '#index?' do
    it 'allows anyone' do
      expect(ArticlePolicy.new(nil, article).index?).to be true
    end
  end

  describe '#show?' do
    it 'allows viewing published articles' do
      expect(ArticlePolicy.new(nil, published_article).show?).to be true
    end

    it 'allows owner to view draft' do
      expect(ArticlePolicy.new(user, article).show?).to be true
    end

    it 'allows admin to view draft' do
      expect(ArticlePolicy.new(admin, article).show?).to be true
    end

    it 'denies other users viewing draft' do
      expect(ArticlePolicy.new(other_user, article).show?).to be false
    end
  end

  describe '#create?' do
    it 'allows logged in users' do
      expect(ArticlePolicy.new(user, Article.new).create?).to be true
    end

    it 'denies guests' do
      expect(ArticlePolicy.new(nil, Article.new).create?).to be false
    end
  end

  describe '#update?' do
    it 'allows owner' do
      expect(ArticlePolicy.new(user, article).update?).to be true
    end

    it 'allows admin' do
      expect(ArticlePolicy.new(admin, article).update?).to be true
    end

    it 'denies other users' do
      expect(ArticlePolicy.new(other_user, article).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'allows owner' do
      expect(ArticlePolicy.new(user, article).destroy?).to be true
    end

    it 'denies other users' do
      expect(ArticlePolicy.new(other_user, article).destroy?).to be false
    end
  end

  describe '#publish?' do
    it 'allows owner' do
      expect(ArticlePolicy.new(user, article).publish?).to be true
    end

    it 'allows admin' do
      expect(ArticlePolicy.new(admin, article).publish?).to be true
    end

    it 'denies other users' do
      expect(ArticlePolicy.new(other_user, article).publish?).to be false
    end
  end
end
