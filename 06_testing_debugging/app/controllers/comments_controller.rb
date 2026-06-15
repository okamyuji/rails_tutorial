class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @article, notice: "コメントを投稿しました。"
    else
      redirect_to @article, alert: "コメントの投稿に失敗しました。"
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    authorize @comment
    @comment.destroy
    redirect_to @article, notice: "コメントを削除しました。"
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
