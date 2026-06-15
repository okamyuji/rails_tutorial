class ArticlesController < ApplicationController
  before_action :set_article, only: %i[show edit update destroy]

  # GET /articles
  def index
    @articles = Article.recent

    respond_to do |format|
      format.html
      format.json { render json: @articles }
    end
  end

  # GET /articles/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: @article }
    end
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
      respond_to do |format|
        format.html { redirect_to @article, notice: "記事を作成しました" }
        format.json { render json: @article, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json do
          render json: {
                   errors: @article.errors
                 },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /articles/:id
  def update
    if @article.update(article_params)
      respond_to do |format|
        format.html { redirect_to @article, notice: "記事を更新しました" }
        format.json { render json: @article }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json do
          render json: {
                   errors: @article.errors
                 },
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "記事を削除しました" }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published, :user_id)
  end
end
