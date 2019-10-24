module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :require_basic_auth_for_ui
    layout 'application'
  end
end
