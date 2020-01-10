module ProviderInterface
  class ProviderAgreementsController < ProviderInterfaceController
    skip_before_action :check_data_sharing_agreements

    def new_data_sharing_agreement
      @provider_agreement = GetPendingDataSharingAgreementsForProviderUser.call(provider_user: current_provider_user).first
      if @provider_agreement
        render :data_sharing_agreement
      else
        redirect_to provider_interface_path
      end
    end

    def create_data_sharing_agreement
      @provider_agreement = ProviderAgreement.new(provider_agreement_params.merge(provider_user: current_provider_user))
      if @provider_agreement.save
        redirect_to provider_interface_path
      else
        render :data_sharing_agreement
      end
    end

    def show_data_sharing_agreement
      @provider_agreement = ProviderAgreement.find_by_id params[:id]
      if @provider_agreement
        render :data_sharing_agreement
      else
        redirect_to provider_interface_path
      end
    end

  private

    def provider_agreement_params
      params.require(:provider_agreement).permit(
        :accept_agreement,
        :agreement_type,
        :provider_id,
      )
    end
  end
end
