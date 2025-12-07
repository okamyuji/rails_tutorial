# frozen_string_literal: true

# 記事のリクエストスペック（統合テスト）
# spec/requests/articles_spec.rb

require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article, user: user) }

  describe 'GET /articles' do
    before { create_list(:article, 3, :published) }

    it 'returns http success' do
      get articles_path
      expect(response).to have_http_status(:success)
    end

    it 'displays articles' do
      get articles_path
      expect(response.body).to include(Article.first.title)
    end
  end

  describe 'GET /articles/:id' do
    it 'returns http success' do
      get article_path(article)
      expect(response).to have_http_status(:success)
    end

    it 'displays the article' do
      get article_path(article)
      expect(response.body).to include(article.title)
    end
  end

  describe 'POST /articles' do
    before { sign_in user }

    let(:valid_params) { { article: attributes_for(:article) } }

    it 'creates a new article' do
      expect {
        post articles_path, params: valid_params
      }.to change(Article, :count).by(1)
    end

    it 'redirects to the created article' do
      post articles_path, params: valid_params
      expect(response).to redirect_to(Article.last)
    end
  end

  describe 'authentication' do
    context 'when not logged in' do
      it 'redirects to login page for create' do
        post articles_path, params: { article: attributes_for(:article) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

