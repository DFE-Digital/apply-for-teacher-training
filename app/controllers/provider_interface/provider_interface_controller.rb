module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :require_basic_auth_for_ui
    layout 'application'

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_user
      fake_user_class = Struct.new(:provider)
      fake_provider_class = Struct.new(:code)
      fake_user_class.new(fake_provider_class.new('ABC'))
    end
  end
end
