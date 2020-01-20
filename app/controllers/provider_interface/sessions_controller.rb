module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    skip_before_action :check_data_sharing_agreements

    def new
      redirect_to provider_interface_applications_path if current_provider_user
    end

    def destroy
      DfESignInUser.end_session!(session)

      redirect_to action: :new
    end

  private

    def default_authenticated_path
      if authorized_for_support_interface?
        support_interface_path
      else
        provider_interface_path
      end
    end

    def authorized_for_support_interface?
      SupportUser.load_from_session(session)
    end
  end
end
