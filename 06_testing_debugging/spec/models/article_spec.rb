require "rails_helper"

RSpec.describe Article, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
  end

  describe "scopes" do
    let!(:published_article) { create(:article, published: true) }
    let!(:draft_article) { create(:article, published: false) }

    it "returns published articles" do
      expect(Article.published).to include(published_article)
      expect(Article.published).not_to include(draft_article)
    end
  end

  describe "#publish!" do
    let(:article) { create(:article, published: false) }

    it "sets published to true" do
      article.publish!
      expect(article.published).to be true
    end

    it "sets published_at to current time" do
      freeze_time do
        article.publish!
        expect(article.published_at).to eq(Time.current)
      end
    end
  end

  describe ".search" do
    let!(:article) do
      create(
        :article,
        title: "Ruby on Rails Tutorial",
        content: "Learn Rails basics"
      )
    end
    let!(:other) do
      create(:article, title: "Python Guide", content: "Learn Python basics")
    end

    it "returns articles matching title" do
      expect(Article.search("Ruby")).to include(article)
      expect(Article.search("Ruby")).not_to include(other)
    end

    it "returns articles matching content" do
      expect(Article.search("Python")).to include(other)
      expect(Article.search("Python")).not_to include(article)
    end

    it "returns all articles when query is blank" do
      expect(Article.search("")).to include(article, other)
    end
  end
end
