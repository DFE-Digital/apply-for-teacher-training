module ProviderInterface
  module Reports
    class WithdrawalsController < ProviderInterfaceController

      def show
        @provider = current_user.providers.find(params[:provider_id])
      end

    end
  end
end
