# frozen_string_literal: true

# 記事ポリシーのテスト
# spec/policies/article_policy_spec.rb

require "rails_helper"

RSpec.describe ArticlePolicy do
  subject { described_class.new(user, article) }

  let(:article) { create(:article) }

  describe "permissions" do
    context "for a guest user" do
      let(:user) { nil }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end

    context "for the article owner" do
      let(:user) { article.user }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "for an admin user" do
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "for a different user" do
      let(:user) { create(:user) }

      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end

  describe "scope" do
    let!(:published_article) { create(:article, :published) }
    let!(:draft_article) { create(:article, published: false) }

    subject { ArticlePolicy::Scope.new(user, Article).resolve }

    context "for an admin user" do
      let(:user) { create(:user, :admin) }

      it "includes all articles" do
        expect(subject).to include(published_article, draft_article)
      end
    end

    context "for a regular user" do
      let(:user) { create(:user) }

      it "includes only published articles" do
        expect(subject).to include(published_article)
        expect(subject).not_to include(draft_article)
      end
    end
  end
end
