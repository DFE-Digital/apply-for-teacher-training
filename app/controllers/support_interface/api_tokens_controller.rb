module SupportInterface
  class APITokensController < SupportInterfaceController
    rescue_from MissingProviderError do
      redirect_to new_support_interface_api_token_path
      flash[:warning] = 'Did not select a provider'
    end

    def index
      @api_tokens = VendorAPIToken.order(
        VendorAPIToken.arel_table[:last_used_at].desc.nulls_last,
        created_at: :desc,
      )
    end

    def new
      @vendor_api_token = VendorAPIToken.new
      @providers_for_select = Provider.all
    end

    def create
      raise_error_unless_provider(params)

      provider = Provider.find(params[:vendor_api_token][:provider_id])
      @unhashed_token = VendorAPIToken.create_with_random_token!(provider:)
    end

    def confirm_revocation; end

    def destroy
      VendorAPIToken.find(params[:id]).destroy!
      redirect_to support_interface_api_tokens_path
    end

  private

    def raise_error_unless_provider(params)
      if params[:vendor_api_token][:provider_id].blank?
        raise MissingProviderError
      end
    end
  end
end
