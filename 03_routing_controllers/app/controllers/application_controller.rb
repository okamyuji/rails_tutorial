class ApplicationController < ActionController::Base
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def record_not_found
    respond_to do |format|
      format.html do
        render file: "#{Rails.root}/public/404.html",
               status: :not_found,
               layout: false
      end
      format.json do
        render json: {
                 errors: [
                   {
                     status: "404",
                     title: "Record Not Found",
                     detail: "The requested resource was not found"
                   }
                 ]
               },
               status: :not_found
      end
    end
  end

  def parameter_missing(exception)
    respond_to do |format|
      format.html { render plain: exception.message, status: :bad_request }
      format.json do
        render json: { error: exception.message }, status: :bad_request
      end
    end
  end

  def record_invalid(exception)
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.json do
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
    end
  end
end
