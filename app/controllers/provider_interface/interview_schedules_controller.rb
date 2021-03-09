module ProviderInterface
  class InterviewSchedulesController < ProviderInterfaceController
    before_action :interview_flag_enabled?

    def show
      @interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .upcoming
        .includes([:provider, application_choice: [:course, course_option: [:site], application_form: [:candidate]]])
        .order(:date_and_time)
        .page(params[:page] || 1).per(50)

      @grouped_interviews = @interviews.group_by(&:date)
    end

    def past
      @interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .past
        .includes([:provider, application_choice: [:course, course_option: [:site], application_form: [:candidate]]])
        .order(date_and_time: :desc)
        .page(params[:page] || 1).per(50)

      @grouped_interviews = @interviews.group_by(&:date)
    end

  private

    def application_choices_for_user_providers
      GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )
    end

    def interview_flag_enabled?
      unless FeatureFlag.active?(:interviews)
        fallback_path = provider_interface_application_choice_path(@application_choice)
        redirect_back(fallback_location: fallback_path)
      end
    end
  end
end
