module RegisterAPI
  class ApplicationsController < ActionController::API
    include APIUserAuthentication

    def index; end
  end
end
