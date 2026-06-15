# frozen_string_literal: true

# CommentsController
# コメントリソースを管理するコントローラです。
# 記事にネストされたリソースとして動作します。
class CommentsController < ApplicationController
  before_action :set_article

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params)

    if @comment.save
      redirect_to @article, notice: "コメントを投稿しました。"
    else
      redirect_to @article, alert: "コメントの投稿に失敗しました。"
    end
  end

  # DELETE /articles/:article_id/comments/:id
  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to @article, notice: "コメントを削除しました。", status: :see_other
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end
end
