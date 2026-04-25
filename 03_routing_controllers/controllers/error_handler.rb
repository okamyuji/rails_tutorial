# frozen_string_literal: true

# ErrorHandler
# エラーハンドリングを共通化するConcernです。
# ApplicationControllerにincludeして使用します。

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    # 例外をキャッチして適切なエラーレスポンスを返します
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from StandardError, with: :internal_server_error
  end

  private

  # レコードが見つからない場合（404）
  def record_not_found(exception)
    render json: {
             errors: [
               {
                 status: "404",
                 code: "not_found",
                 title: "Record Not Found",
                 detail: exception.message
               }
             ]
           },
           status: :not_found
  end

  # バリデーションエラーの場合（422）
  def record_invalid(exception)
    render json: {
             errors:
               exception.record.errors.map do |error|
                 {
                   status: "422",
                   code: "validation_failed",
                   title: "Validation Failed",
                   detail: error.full_message,
                   source: {
                     pointer: "/data/attributes/#{error.attribute}"
                   }
                 }
               end
           },
           status: :unprocessable_entity
  end

  # 必須パラメータが欠けている場合（400）
  def parameter_missing(exception)
    render json: {
             errors: [
               {
                 status: "400",
                 code: "parameter_missing",
                 title: "Parameter Missing",
                 detail: exception.message
               }
             ]
           },
           status: :bad_request
  end

  # その他のサーバーエラー（500）
  def internal_server_error(exception)
    # 本番環境では詳細なエラー情報を隠す
    if Rails.env.production?
      render json: {
               errors: [
                 {
                   status: "500",
                   code: "internal_server_error",
                   title: "Internal Server Error",
                   detail: "An unexpected error occurred"
                 }
               ]
             },
             status: :internal_server_error
    else
      # 開発環境では詳細な情報を表示
      render json: {
               errors: [
                 {
                   status: "500",
                   code: "internal_server_error",
                   title: "Internal Server Error",
                   detail: exception.message,
                   backtrace: exception.backtrace.first(10)
                 }
               ]
             },
             status: :internal_server_error
    end
  end
end

# ApplicationControllerでの使用例:
#
# class ApplicationController < ActionController::API
#   include ErrorHandler
# end
