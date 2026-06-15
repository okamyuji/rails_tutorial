require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article, :published, user: user) }

  describe 'POST /articles/:article_id/comments' do
    before { sign_in user }

    it 'creates a comment' do
      expect {
        post article_comments_path(article), params: { comment: { content: 'Nice post!' } }
      }.to change(Comment, :count).by(1)
    end

    it 'redirects to the article' do
      post article_comments_path(article), params: { comment: { content: 'Nice post!' } }
      expect(response).to redirect_to(article_path(article))
    end

    it 'sets current_user as commenter' do
      post article_comments_path(article), params: { comment: { content: 'Nice post!' } }
      expect(Comment.last.user).to eq(user)
    end
  end

  describe 'POST /articles/:article_id/comments (unauthenticated)' do
    it 'redirects to sign in' do
      post article_comments_path(article), params: { comment: { content: 'Nice!' } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'DELETE /articles/:article_id/comments/:id' do
    before { sign_in user }

    let!(:comment) { create(:comment, article: article, user: user) }

    it 'deletes the comment' do
      expect {
        delete article_comment_path(article, comment)
      }.to change(Comment, :count).by(-1)
    end
  end
end
