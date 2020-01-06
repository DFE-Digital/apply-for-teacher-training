module ProviderInterface
  class ContentController < ProviderInterfaceController
    include ContentHelper
    skip_before_action :authenticate_provider_user!
    skip_before_action :check_data_sharing_agreements
    layout 'application'

    helper_method :current_provider_user

    def accessibility
      render_content_page :accessibility
    end

    def privacy_policy
      render_content_page :privacy_policy
    end

    def cookies_provider
      render_content_page :cookies_provider
    end

    def terms_provider
      render_content_page :terms_provider
    end
  end
end
