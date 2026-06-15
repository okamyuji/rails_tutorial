# frozen_string_literal: true

# CommentsController
# コメントリソースを管理するコントローラです。
# 記事にネストした作成のみを提供します。
class CommentsController < ApplicationController
  before_action :set_article, only: %i[create]

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to @article, notice: "コメントを投稿しました。" }
        format.turbo_stream
      else
        format.html { redirect_to @article, alert: "コメントの投稿に失敗しました。" }
      end
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
