module ProviderInterface
  class StartPageController < ProviderInterfaceController
    before_action :redirect_authenticated_provider_user
    skip_before_action :authenticate_provider_user!, :check_data_sharing_agreements

    layout 'base'

    def show
      courses = Course.includes(:provider).open_on_apply
      @course_count = courses.count
      @provider_count = courses.map(&:provider).uniq.count

      @pilot_enrolment_form_url = 'https://forms.gle/p4zZP51LEji8v1hp6'
    end

    def redirect_authenticated_provider_user
      if current_provider_user || dfe_sign_in_user
        redirect_to(provider_interface_applications_path)
      end
    end
  end
end
