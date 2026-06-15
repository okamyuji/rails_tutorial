# frozen_string_literal: true

# ArticlesController
# 記事リソースのCRUDを管理するコントローラです。
class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]

  # GET /articles
  def index
    @articles = Article.includes(:user).recent
    @articles = @articles.search(params[:q]) if params[:q].present?
  end

  # GET /articles/:id
  def show
    @comments = @article.comments.includes(:user).order(created_at: :desc)
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
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: "記事を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/:id
  def update
    if @article.update(article_params)
      redirect_to @article, notice: "記事を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy
    redirect_to articles_url, notice: "記事を削除しました。", status: :see_other
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published, :user_id)
  end
end
