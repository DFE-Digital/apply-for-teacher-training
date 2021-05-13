module ProviderInterface
  class InterviewSchedulesController < ProviderInterfaceController
    def show
      @interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .upcoming
        .includes([:provider, application_choice: [:course_option, application_form: [:candidate]]])
        .order(:date_and_time)
        .page(params[:page] || 1).per(50)

      @grouped_interviews = @interviews.group_by(&:date)
    end

    def past
      @interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .past
        .includes([:provider, application_choice: [:course_option, application_form: [:candidate]]])
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
  end
end
