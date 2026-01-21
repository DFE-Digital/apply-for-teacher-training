module ProviderInterface
  class ProviderAgreementsController < ProviderInterfaceController
    def new_data_sharing_agreement
      @provider_agreement = ProviderSetup.new(provider_user: current_provider_user).next_agreement_pending

      if @provider_agreement
        render :data_sharing_agreement
      else
        redirect_to provider_interface_path
      end
    end

    def old_data_sharing_agreement
      render :old_data_sharing_agreement
    end

    def create_data_sharing_agreement
      support_impersonator = Current.support_session&.user

      if support_impersonator && HostingEnvironment.production?
        flash[:warning] = 'Cannot be signed by a support user'
        redirect_to(provider_interface_new_data_sharing_agreement_path) and return
      end

      @provider_agreement = ProviderAgreement.new(provider_agreement_params.merge(provider_user: current_provider_user))

      render :data_sharing_agreement and return unless @provider_agreement.save

      @provider_setup = ProviderSetup.new(provider_user: current_provider_user)
      @provider_relationship_pending = @provider_setup.next_relationship_pending.present?

      render :success and return if @provider_setup.next_agreement_pending.blank?

      redirect_to provider_interface_new_data_sharing_agreement_path
    end

  private

    def provider_agreement_params
      params.expect(
        provider_agreement: %i[accept_agreement
                               agreement_type
                               provider_id],
      )
    end
  end
end
