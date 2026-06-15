require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: user) }

  describe 'GET /articles' do
    it 'returns http success' do
      get articles_path
      expect(response).to have_http_status(:success)
    end

    it 'displays articles' do
      article
      get articles_path
      expect(response.body).to include(article.title)
    end
  end

  describe 'GET /articles/:id' do
    it 'returns http success for published article' do
      get article_path(article)
      expect(response).to have_http_status(:success)
    end

    it 'displays article content' do
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

    it 'returns http redirect' do
      post articles_path, params: valid_params
      expect(response).to have_http_status(:redirect)
    end

    it 'sets current_user as author' do
      post articles_path, params: valid_params
      expect(Article.last.user).to eq(user)
    end
  end

  describe 'POST /articles (unauthenticated)' do
    it 'redirects to sign in page' do
      post articles_path, params: { article: attributes_for(:article) }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'DELETE /articles/:id' do
    before { sign_in user }

    it 'deletes the article' do
      article
      expect {
        delete article_path(article)
      }.to change(Article, :count).by(-1)
    end
  end

  describe 'PATCH /articles/:id/publish' do
    before { sign_in user }

    let(:draft_article) { create(:article, user: user, published: false) }

    it 'publishes the article' do
      patch publish_article_path(draft_article)
      expect(draft_article.reload.published).to be true
    end

    it 'redirects to the article' do
      patch publish_article_path(draft_article)
      expect(response).to redirect_to(article_path(draft_article))
    end
  end
end
