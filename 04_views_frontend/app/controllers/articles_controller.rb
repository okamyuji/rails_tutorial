# frozen_string_literal: true

# ArticlesController
# 記事リソースを管理するRESTfulコントローラです。
# HTML / Turbo Stream の両方に応答します。
class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]

  # GET /articles
  def index
    @articles = Article.includes(:user, :comments).recent
    @articles = @articles.search(params[:q]) if params[:q].present?
  end

  # GET /articles/:id
  def show
    @comment = Comment.new
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/:id/edit
  def edit
  end

  # POST /articles
  def create
    @article = current_user.articles.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "記事を作成しました。" }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/:id
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "記事を更新しました。" }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "記事を削除しました。", status: :see_other }
      format.turbo_stream
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published)
  end
end
