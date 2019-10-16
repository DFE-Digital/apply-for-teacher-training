class ErrorsController < ApplicationController
  def not_found
    render 'not_found.html', status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
