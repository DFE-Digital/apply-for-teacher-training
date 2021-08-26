module ProviderInterface
  class StartPageController < ProviderInterfaceController
    COURSES_COUNT_CACHE_KEY = 'provider_interface_courses_count'.freeze
    PROVIDERS_COUNT_CACHE_KEY = 'provider_interface_providers_count'.freeze
    before_action :redirect_authenticated_provider_user
    skip_before_action :authenticate_provider_user!

    layout 'base'

    def show
      @course_count = Rails.cache.fetch(COURSES_COUNT_CACHE_KEY, expires_in: 24.hours) do
        Course.current_cycle.open_on_apply.count
      end
      @provider_count = Rails.cache.fetch(PROVIDERS_COUNT_CACHE_KEY, expires_in: 24.hours) do
        Course.current_cycle.includes(:provider).open_on_apply.map(&:provider).uniq.count
      end

      session['post_dfe_sign_in_path'] = provider_interface_applications_path
    end

    def redirect_authenticated_provider_user
      if current_provider_user
        redirect_to(provider_interface_applications_path)
      end
    end
  end
end
