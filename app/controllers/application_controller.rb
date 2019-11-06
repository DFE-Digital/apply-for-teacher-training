class ApplicationController < ActionController::Base
  include ParamsLogging
  before_action :add_params_to_request_store
end
