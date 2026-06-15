class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_article, only: %i[show edit update destroy publish]

  def index
    @articles = Article.includes(:user).published.recent
  end

  def show
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      redirect_to @article, notice: "記事を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @article
  end

  def update
    authorize @article

    if @article.update(article_params)
      redirect_to @article, notice: "記事を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @article
    @article.destroy
    redirect_to articles_path, notice: "記事を削除しました。"
  end

  def publish
    authorize @article
    @article.publish!
    redirect_to @article, notice: "記事を公開しました。"
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published)
  end
end
