class ApplicationController < ActionController::Base
  include LogQueryParams
  include EmitRequestEvents

  def current_user; end
end
