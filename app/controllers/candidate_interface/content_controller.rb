module CandidateInterface
  class ContentController < CandidateInterfaceController
    include ContentHelper
    skip_before_action :authenticate_candidate!
    skip_before_action :require_authentication
    skip_before_action :set_user_context

    def accessibility
      render 'content/accessibility_candidate'
    end

    def privacy_policy
      render 'content/service_privacy_notice_candidate'
    end

    def cookies_page
      @application = :apply
      @cookie_ga_code = ENV.fetch('GOOGLE_ANALYTICS_APPLY', '').gsub('-', '_')
      @cookie_preferences = CookiePreferencesForm.new(consent: cookies['consented-to-apply-cookies'])
      @cookie_settings_path = candidate_interface_cookie_preferences_path
      session[:previous_referer] = request.referer

      render 'content/cookies'
    end

    def terms_candidate
      render 'content/terms_candidate'
    end

    def guidance_for_using_ai
      render 'content/guidance_for_using_ai'
    end

    def complaints
      render 'content/complaints'
    end
  end
end
