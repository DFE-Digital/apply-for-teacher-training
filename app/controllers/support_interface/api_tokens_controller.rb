module SupportInterface
  class APITokensController < SupportInterfaceController
    def index
      @api_tokens_last_3_months_count = VendorAPIToken.used_in_last_3_months.count
      @filter = SupportInterface::VendorAPITokenFilter.new(
        filter_params:,
      )
      @pagy, @api_tokens = pagy(@filter.filtered_tokens)

      respond_to do |format|
        format.csv do
          send_data(
            SupportInterface::VendorAPITokensCSVExport.call(
              vendor_tokens: @filter.filtered_tokens,
            ),
            format: 'text/csv',
            filename: "Providers with api tokens #{Date.current}.csv",
          )
        end

        format.html
      end
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

    def filter_params
      params.permit(vendor_ids: [])
    end

    def vendor_api_token_params
      params.expect(vendor_api_token: [:provider_id])
    end
  end
end
