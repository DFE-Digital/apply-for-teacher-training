module ProviderInterface
  class InterviewSchedulesController < ProviderInterfaceController
    def show
      @grouped_interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .includes([:provider, application_choice: [:course_option, application_form: [:candidate]]])
        .where('date_and_time >= ?', Time.zone.now)
        .order(:date_and_time).group_by(&:date)
    end

    def past
      @grouped_interviews = Interview.for_application_choices(application_choices_for_user_providers)
        .undiscarded
        .includes([:provider, application_choice: [:course_option, application_form: [:candidate]]])
        .where('date_and_time < ?', Time.zone.now)
        .order(date_and_time: :desc).group_by(&:date)
    end

  private

    def application_choices_for_user_providers
      GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )
    end
  end
end
