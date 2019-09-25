RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
end

# The Devise test helpers rely on an ApplicationController being present
class ApplicationController < ActionController::Base; end
