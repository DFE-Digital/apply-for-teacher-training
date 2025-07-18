module ProviderInterface
  class APITokensController < ProviderInterfaceController
    before_action :set_provider
    before_action :redirect_unless_can_manage_api_tokens, only: %i[create new]

    def index
      @api_tokens = @provider.vendor_api_tokens.order(:last_used_at)
      @can_manage_tokens = current_provider_user.authorisation.can_manage_api_tokens?(@provider)
    end

    def new
      @api_token = @provider.vendor_api_tokens.new
    end

    def create
      @unhashed_token = VendorAPIToken.create_with_random_token!(provider: @provider)
      render :show
    end

  private

    def redirect_unless_can_manage_api_tokens
      unless current_provider_user.authorisation.can_manage_api_tokens?(@provider)
        redirect_to provider_interface_organisation_settings_path
      end
    end

    def set_provider
      @provider = current_provider_user.providers.find(params[:organisation_id])
    end
  end
end
