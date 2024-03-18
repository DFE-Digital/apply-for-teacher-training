module ProviderInterface
  class StartPageController < ProviderInterfaceController
    PROVIDERS_AND_COURSES_COUNT_CACHE_KEY = 'provider_interface_providers_and_courses_count'.freeze
    before_action :redirect_authenticated_provider_user
    skip_before_action :authenticate_provider_user!

    layout 'base'

    def show
      @provider_and_courses_cache_key = PROVIDERS_AND_COURSES_COUNT_CACHE_KEY
      session['post_dfe_sign_in_path'] = provider_interface_applications_path
    end

    def redirect_authenticated_provider_user
      if current_provider_user
        redirect_to(provider_interface_applications_path)
      end
    end
  end
end
