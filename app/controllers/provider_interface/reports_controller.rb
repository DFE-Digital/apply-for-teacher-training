module ProviderInterface
  class ReportsController < ProviderInterfaceController
    def index
      @providers = current_user.providers
    end
  end
end
