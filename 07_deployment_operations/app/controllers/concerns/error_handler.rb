# frozen_string_literal: true

# ErrorHandler
# エラーハンドリングを共通化するConcernです。
# ApplicationControllerにincludeして使用します。
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
  end

  private

  # レコードが見つからない場合（404）
  def record_not_found(exception)
    respond_to do |format|
      format.html do
        render file: Rails.public_path.join("404.html"),
               status: :not_found,
               layout: false
      end
      format.json do
        render json: { error: exception.message }, status: :not_found
      end
    end
  end

  # バリデーションエラーの場合（422）
  def record_invalid(exception)
    respond_to do |format|
      format.html do
        render file: Rails.public_path.join("422.html"),
               status: :unprocessable_entity,
               layout: false
      end
      format.json do
        render json: {
                 errors:
                   exception.record.errors.map { |e|
                     { field: e.attribute, message: e.full_message }
                   }
               },
               status: :unprocessable_entity
      end
    end
  end

  # 必須パラメータが欠けている場合（400）
  def parameter_missing(exception)
    respond_to do |format|
      format.html do
        render file: Rails.public_path.join("400.html"),
               status: :bad_request,
               layout: false
      end
      format.json do
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end
end
