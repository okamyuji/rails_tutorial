# frozen_string_literal: true

# ArticlesController
# 記事リソースを管理するRESTful APIコントローラです。
# 標準的な7つのアクション（index, show, create, update, destroy）を実装しています。

module Api
  module V1
    class ArticlesController < ApplicationController
      before_action :set_article, only: [:show, :update, :destroy]

      # GET /api/v1/articles
      # 記事の一覧を取得します
      def index
        @articles = Article.includes(:user).order(created_at: :desc)
        
        # ページネーション
        @articles = @articles.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          articles: @articles.as_json(include: { user: { only: [:id, :name] } }),
          meta: pagination_meta(@articles)
        }
      end

      # GET /api/v1/articles/:id
      # 特定の記事を取得します
      def show
        render json: @article.as_json(
          include: {
            user: { only: [:id, :name, :email] },
            comments: { include: { user: { only: [:id, :name] } } }
          }
        )
      end

      # POST /api/v1/articles
      # 新しい記事を作成します
      def create
        @article = Article.new(article_params)
        
        if @article.save
          render json: @article, status: :created
        else
          render json: { errors: format_errors(@article.errors) }, 
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/articles/:id
      # 記事を更新します
      def update
        if @article.update(article_params)
          render json: @article
        else
          render json: { errors: format_errors(@article.errors) }, 
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/articles/:id
      # 記事を削除します
      def destroy
        @article.destroy
        head :no_content
      end

      # カスタムアクション
      # POST /api/v1/articles/:id/publish
      # 記事を公開します
      def publish
        @article = Article.find(params[:id])
        
        if @article.update(published: true, published_at: Time.current)
          render json: @article
        else
          render json: { errors: format_errors(@article.errors) }, 
                 status: :unprocessable_entity
        end
      end

      # POST /api/v1/articles/:id/unpublish
      # 記事を非公開にします
      def unpublish
        @article = Article.find(params[:id])
        
        if @article.update(published: false, published_at: nil)
          render json: @article
        else
          render json: { errors: format_errors(@article.errors) }, 
                 status: :unprocessable_entity
        end
      end

      # GET /api/v1/articles/published
      # 公開済みの記事のみを取得します
      def published
        @articles = Article.where(published: true)
                          .includes(:user)
                          .order(published_at: :desc)
        
        render json: {
          articles: @articles.as_json(include: { user: { only: [:id, :name] } })
        }
      end

      private

      # 記事を検索して設定します
      def set_article
        @article = Article.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Article not found' }, status: :not_found
      end

      # Strong Parameters
      # 許可するパラメータを定義します
      def article_params
        params.require(:article).permit(:title, :content, :published, :user_id)
      end

      # エラーメッセージを整形します
      def format_errors(errors)
        errors.map do |error|
          {
            field: error.attribute,
            message: error.full_message
          }
        end
      end

      # ページネーション情報を生成します
      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
