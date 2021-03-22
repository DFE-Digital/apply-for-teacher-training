module RegisterAPI
  class ApplicationsController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include APIUserAuthentication

    def index; end
  end
end
