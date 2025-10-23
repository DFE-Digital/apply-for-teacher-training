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

    def privacy; end

    def cookies_page
      @application = :manage
      @cookie_ga_code = ENV.fetch('GOOGLE_ANALYTICS_MANAGE', '').gsub('-', '_')
      @cookie_preferences = CookiePreferencesForm.new(consent: cookies['consented-to-manage-cookies'])
      @cookie_settings_path = provider_interface_cookie_preferences_path
      session[:previous_referer] = request.referer

      render 'content/cookies'
    end

    def service_guidance_provider; end

    def dates_and_deadlines
      @timetables = [current_timetable, current_timetable.relative_next_timetable]
    end

    def roadmap; end

    def organisation_permissions
      render_content_page :organisation_permissions,
                          breadcrumb_title: 'service_guidance_provider',
                          breadcrumb_path: provider_interface_service_guidance_path
    end
  end
end
