module CandidateInterface
  class ContentController < CandidateInterfaceController
    include ContentHelper
    skip_before_action :authenticate_candidate!
    skip_before_action :set_user_context

    def accessibility
      render_content_page :accessibility
    end

    def privacy_policy
      render_content_page :privacy_policy
    end

    def cookies_page
      @application = :apply
      @cookie_ga_code = ENV.fetch('GOOGLE_ANALYTICS_APPLY', '').gsub(/-/, '_')
      @cookie_preferences = CookiePreferencesForm.new(consent: cookies['consented-to-apply-cookies'])
      @cookie_settings_path = candidate_interface_cookie_preferences_path
      session[:previous_referer] = request.referer

      render 'content/cookies'
    end

    def terms_candidate
      render_content_page :terms_candidate
    end

    def complaints
      render_content_page :complaints
    end

    ProviderCourses = Struct.new(:provider_name, :courses)
    RegionProviderCourses = Struct.new(:region_code, :provider_name, :courses)

    def providers
      @courses_by_provider_and_region = courses_grouped_by_provider_and_region
    end

  private

    def courses_grouped_by_provider_and_region
      Course
        .open_on_apply
        .current_cycle
        .includes(:provider)
        .order('providers.region_code', 'providers.name')
        .group_by { |course| [course.provider.region_code, course.provider.name] }
        .map { |region_provider, courses| RegionProviderCourses.new(region_provider[0], region_provider[1], courses) }
        .group_by(&:region_code)
    end
  end
end
