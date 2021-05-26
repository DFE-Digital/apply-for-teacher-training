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

    def cookies_page
      @application = :manage
      @cookie_ga_code = ENV.fetch('GOOGLE_ANALYTICS_MANAGE', '').gsub(/-/, '_')
      @cookie_preferences = CookiePreferencesForm.new(consent: cookies['consented-to-manage-cookies'])
      @cookie_settings_path = provider_interface_cookie_preferences_path
      session[:previous_referer] = request.referer

      render 'content/cookies'
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

    def roadmap
      render_content_page :roadmap
    end
  end
end
