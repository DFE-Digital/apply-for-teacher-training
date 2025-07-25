module ProviderInterface
  class APITokensController < ProviderInterfaceController
    before_action :redirect_if_feature_flag_inactive
    before_action :set_provider
    before_action :redirect_unless_can_manage_api_tokens, only: %i[create new]

    def index
      @api_tokens = @provider.vendor_api_tokens.order(:last_used_at)
      @can_manage_tokens = current_provider_user.authorisation.can_manage_api_tokens?(@provider)
    end

    def new
      @api_token = APITokenForm.new(provider: @provider)
    end

    def create
      @api_token = APITokenForm.new(description_param, provider: @provider)
      if @api_token.valid?
        @unhashed_token = @api_token.save!
        render :show
      else
        render :new
      end
    end

  private

    def description_param
      params.expect(provider_interface_api_token_form: :description)
    end

    def redirect_if_feature_flag_inactive
      if FeatureFlag.inactive?(:api_token_management)
        redirect_to provider_interface_organisation_settings_path
      end
    end

    def redirect_unless_can_manage_api_tokens
      unless current_provider_user.authorisation.can_manage_api_tokens?(@provider)
        redirect_to provider_interface_organisation_settings_path
      end
    end

    def set_provider
      @provider = current_provider_user.providers.find(params.expect(:organisation_id))
    end
  end
end
