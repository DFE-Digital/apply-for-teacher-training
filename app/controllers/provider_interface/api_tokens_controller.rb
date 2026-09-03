module ProviderInterface
  class APITokensController < ProviderInterfaceController
    before_action :set_provider
    before_action :set_api_token, only: %i[confirm_revoke revoke show]
    before_action :set_permissions
    before_action :redirect_unless_can_manage_api_tokens, only: %i[create new revoke confirm_revoke]

    def index
      @api_tokens = if params[:filter_tab] == 'revoked'
                      @provider.vendor_api_tokens.discarded.order(:last_used_at)
                    else
                      @provider.vendor_api_tokens.undiscarded.order(:last_used_at)
                    end
      @total_tokens = @provider.vendor_api_tokens.count
    end

    def show; end

    def new
      @api_token = APITokenForm.new(provider: @provider)
    end

    def create
      @api_token = APITokenForm.new(api_token_params.merge(provider: @provider))
      if (@unhashed_token = @api_token.save!)
        render :success
      else
        render :new, status: :unprocessable_content
      end
    end

    def confirm_revoke; end

    def revoke
      @api_token.discard
      flash[:success] = t('.success')
      redirect_to provider_interface_organisation_settings_organisation_api_tokens_path(@provider)
    end

  private

    def api_token_params
      request_params.except(:vendor_name, :vendor_name_raw).merge(
        vendor_name: request_params[:vendor_name_raw]&.downcase ||
          request_params[:vendor_name]&.downcase,
      )
    end

    def request_params
      strip_whitespace(
        params.expect(
          provider_interface_api_token_form: %i[
            description
            vendor_type
            vendor_name
            vendor_name_raw
          ],
        ),
      )
    end

    def redirect_unless_can_manage_api_tokens
      unless current_provider_user.authorisation.can_manage_api_tokens?(@provider)
        redirect_to provider_interface_organisation_settings_path
      end
    end

    def set_provider
      @provider = current_provider_user.providers.find(params.expect(:organisation_id))
    end

    def set_permissions
      @can_manage_tokens = current_provider_user.authorisation.can_manage_api_tokens?(@provider)
    end

    def set_api_token
      @api_token = @provider.vendor_api_tokens.find(params.require(:id))
    end
  end
end
