# frozen_string_literal: true

# UsersController
# ユーザーリソースを管理するRESTful APIコントローラです。

module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy]

      # GET /api/v1/users
      # ユーザーの一覧を取得します
      def index
        @users = User.order(created_at: :desc)

        # 検索機能
        @users = @users.where("name LIKE ?", "%#{params[:q]}%") if params[
          :q
        ].present?

        render json: {
                 users: @users.as_json(except: %i[created_at updated_at])
               }
      end

      # GET /api/v1/users/:id
      # 特定のユーザーを取得します
      def show
        render json:
                 @user.as_json(
                   include: {
                     articles: {
                       only: %i[id title published]
                     }
                   }
                 )
      end

      # POST /api/v1/users
      # 新しいユーザーを作成します
      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: :created
        else
          render json: {
                   errors: format_errors(@user.errors)
                 },
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      # ユーザーを更新します
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: {
                   errors: format_errors(@user.errors)
                 },
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      # ユーザーを削除します
      def destroy
        @user.destroy
        head :no_content
      end

      private

      # ユーザーを検索して設定します
      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end

      # Strong Parameters
      def user_params
        params.require(:user).permit(:name, :email)
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
