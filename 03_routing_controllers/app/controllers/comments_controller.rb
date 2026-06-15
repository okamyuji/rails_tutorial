class CommentsController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :set_article, only: %i[index create]
  before_action :set_comment, only: %i[show update destroy]

  # GET /articles/:article_id/comments
  def index
    @comments = @article.comments.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end

  # GET /comments/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: @comment }
    end
  end

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params)

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @article, notice: "コメントを投稿しました" }
        format.json { render json: @comment, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @article, alert: "コメントの投稿に失敗しました" }
        format.json do
          render json: {
                   errors: @comment.errors
                 },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /comments/:id
  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.html { redirect_to @comment.article, notice: "コメントを更新しました" }
        format.json { render json: @comment }
      end
    else
      respond_to do |format|
        format.html { redirect_to @comment.article, alert: "コメントの更新に失敗しました" }
        format.json do
          render json: {
                   errors: @comment.errors
                 },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /comments/:id
  def destroy
    article = @comment.article
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to article, notice: "コメントを削除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :user_id)
  end
end
