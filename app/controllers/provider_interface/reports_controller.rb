module ProviderInterface
  class ReportsController < ProviderInterfaceController
    def index
      @providers = current_user.providers
      @current_user = current_user
    end
  end
end
