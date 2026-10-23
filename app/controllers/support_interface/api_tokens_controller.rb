module SupportInterface
  class APITokensController < SupportInterfaceController
    before_action :set_token, only: %i[show confirm_revocation revoke]

    def index
      authorize nil, :show?, policy_class: SupportInterface::ProviderPolicy

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

    def show
      authorize nil, :show?, policy_class: SupportInterface::ProviderPolicy

      @can_manage_tokens = true
    end

    def confirm_revocation
      authorize nil, :destroy?, policy_class: SupportInterface::ProviderPolicy

      @revoke_token_form = RevokeTokenForm.new
    end

    def revoke
      authorize nil, :destroy?, policy_class: SupportInterface::ProviderPolicy

      @revoke_token_form = RevokeTokenForm.new(
        api_token: @api_token,
        audit_comment: revoke_params[:audit_comment],
      )

      if @revoke_token_form.save
        flash[:success] = t('.success', token: @api_token.description)
        redirect_to support_interface_api_tokens_path
      else
        render :confirm_revocation
      end
    end

  private

    def set_token
      @api_token = VendorAPIToken.find(params.expect(:id))
    end

    def filter_params
      params.permit(
        :filter_tab,
        :provider_name_or_code,
        :token_name,
        vendor_ids: [],
        activity: [],
      )
    end

    def revoke_params
      params.expect(support_interface_revoke_token_form: [:audit_comment])
    end
  end
end
