class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    render 'not_found', status: :not_found, formats: :html
  end

  def unprocessable_entity
    render 'unprocessable_entity', status: :unprocessable_entity, formats: %i[html]
  end

  def not_acceptable
    respond_to do |format|
      format.any do
        head 406, content_type: 'text/html'
      end
    end
  end

  def internal_server_error
    respond_to do |format|
      format.json do
        render json: {
          errors: [
            {
              error: 'InternalServerError',
              message: 'The server encountered an unexpected condition that prevented it from fulfilling the request',
            },
          ],
        }, status: :internal_server_error
      end

      format.any do
        render 'internal_server_error', status: :internal_server_error, formats: %i[html]
      end
    end
  end
end
