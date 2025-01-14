module SupportInterface
  class APITokensController < SupportInterfaceController
    def index
      @api_tokens = VendorAPIToken.order(
        VendorAPIToken.arel_table[:last_used_at].desc.nulls_last,
        created_at: :desc,
      )
    end

    def new
      @vendor_api_token = VendorAPITokenForm.new
      @providers_for_select = @vendor_api_token.providers_for_select
    end

    def create
      @vendor_api_token = VendorAPITokenForm.new(vendor_api_token_params)

      if (@unhashed_token = @vendor_api_token.save)
        render :show
      else
        @providers_for_select = @vendor_api_token.providers_for_select
        render :new, status: :unprocessable_entity
      end
    end

    def confirm_revocation; end

    def destroy
      VendorAPIToken.find(params[:id]).destroy!
      redirect_to support_interface_api_tokens_path
    end

  private

    def vendor_api_token_params
      params.expect(vendor_api_token: [:provider_id])
    end
  end
end
