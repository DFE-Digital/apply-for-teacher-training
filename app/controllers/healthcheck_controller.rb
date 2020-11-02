class HealthcheckController < ApplicationController
  def show; end

  def version
    render json: { version: ENV['SHA'] }
  end
end
