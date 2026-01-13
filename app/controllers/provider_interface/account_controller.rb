module ProviderInterface
  class AccountController < ProviderInterfaceController
    skip_before_action :redirect_unless_user_associated_with_an_organisation

    rescue_from ProviderUserWithoutOrganisationError, with: :redirect_to_your_account

    def show; end

  private

    def redirect_to_your_account
      redirect_to provider_interface_account_path
    end
  end
end
