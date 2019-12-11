class ErrorsController < ApplicationController
  def not_found
    render 'not_found.html', status: :not_found
  end

  def unprocessable_entity
    render 'unprocessable_entity.html', status: :unprocessable_entity
  end

  def not_acceptable
    respond_to do |format|
      format.any do
        head 406, content_type: 'text/html'
      end
    end
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
