module ProviderInterface
  class AccountController < ProviderInterfaceController
    skip_before_action :redirect_unless_user_associated_with_an_organisation

    def show; end
  end
end
