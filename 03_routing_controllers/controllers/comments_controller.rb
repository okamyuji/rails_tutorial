# frozen_string_literal: true

# CommentsController
# コメントリソースを管理するRESTful APIコントローラです。
# ネストしたリソースとして実装されています。

module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_article, only: %i[index create]
      before_action :set_comment, only: %i[show update destroy]

      # GET /api/v1/articles/:article_id/comments
      # 特定の記事のコメント一覧を取得します
      def index
        @comments = @article.comments.includes(:user).order(created_at: :desc)

        render json: {
                 comments:
                   @comments.as_json(include: { user: { only: %i[id name] } })
               }
      end

      # GET /api/v1/comments/:id
      # 特定のコメントを取得します
      def show
        render json:
                 @comment.as_json(
                   include: {
                     user: {
                       only: %i[id name]
                     },
                     article: {
                       only: %i[id title]
                     }
                   }
                 )
      end

      # POST /api/v1/articles/:article_id/comments
      # 新しいコメントを作成します
      def create
        @comment = @article.comments.new(comment_params)

        if @comment.save
          render json: @comment, status: :created
        else
          render json: {
                   errors: format_errors(@comment.errors)
                 },
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/comments/:id
      # コメントを更新します
      def update
        if @comment.update(comment_params)
          render json: @comment
        else
          render json: {
                   errors: format_errors(@comment.errors)
                 },
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/comments/:id
      # コメントを削除します
      def destroy
        @comment.destroy
        head :no_content
      end

      private

      # 記事を検索して設定します
      def set_article
        @article = Article.find(params[:article_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Article not found" }, status: :not_found
      end

      # コメントを検索して設定します
      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Comment not found" }, status: :not_found
      end

      # Strong Parameters
      def comment_params
        params.require(:comment).permit(:content, :user_id)
      end

      # エラーメッセージを整形します
      def format_errors(errors)
        errors.map do |error|
          { field: error.attribute, message: error.full_message }
        end
      end
    end
  end
end
