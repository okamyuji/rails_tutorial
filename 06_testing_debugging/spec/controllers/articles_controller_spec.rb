# frozen_string_literal: true

# 記事コントローラのテスト
# spec/controllers/articles_controller_spec.rb

require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  let(:user) { create(:user) }
  let(:article) { create(:article, user: user) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @articles' do
      article
      get :index
      expect(assigns(:articles)).to include(article)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: article.id }
      expect(response).to be_successful
    end

    it 'assigns the requested article' do
      get :show, params: { id: article.id }
      expect(assigns(:article)).to eq(article)
    end
  end

  describe 'POST #create' do
    before { sign_in user }

    context 'with valid params' do
      let(:valid_attributes) { attributes_for(:article) }

      it 'creates a new Article' do
        expect {
          post :create, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)
      end

      it 'redirects to the created article' do
        post :create, params: { article: valid_attributes }
        expect(response).to redirect_to(Article.last)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:article, title: '') }

      it 'does not create a new Article' do
        expect {
          post :create, params: { article: invalid_attributes }
        }.not_to change(Article, :count)
      end
    end
  end

  describe 'PUT #update' do
    before { sign_in user }

    context 'with valid params' do
      let(:new_attributes) { { title: 'Updated Title' } }

      it 'updates the requested article' do
        put :update, params: { id: article.id, article: new_attributes }
        article.reload
        expect(article.title).to eq('Updated Title')
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in user }

    it 'destroys the requested article' do
      article
      expect {
        delete :destroy, params: { id: article.id }
      }.to change(Article, :count).by(-1)
    end
  end
end

