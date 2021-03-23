module RegisterAPI
  class ApplicationsController < ActionController::API
    include ServiceAPIUserAuthentication

    def index; end
  end
end
