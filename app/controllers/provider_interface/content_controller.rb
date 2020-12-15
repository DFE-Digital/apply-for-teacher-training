module ProviderInterface
  class ContentController < ProviderInterfaceController
    include ContentHelper
    skip_before_action :authenticate_provider_user!
    skip_before_action :redirect_if_setup_required
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

    def service_guidance_provider
      render_content_page :service_guidance_provider
    end

    def guidance_for_the_new_cycle
      render_content_page :guidance_for_the_new_cycle
    end

    def complaints
      render_content_page :complaints
    end
  end
end
