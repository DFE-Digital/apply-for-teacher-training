module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :blanket_basic_auth
    layout 'application'
  end
end
