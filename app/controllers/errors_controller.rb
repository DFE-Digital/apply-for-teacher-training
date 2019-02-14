class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
    only: %i[not_found internal_server_error forbidden unauthorised]

  skip_before_action :authenticate_candidate!,
    only: %i[not_found internal_server_error forbidden unauthorised]

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def forbidden
    render status: :forbidden
  end
end
