module ProviderInterface
  class InterviewSchedulesController < ProviderInterfaceController
    def show
      application_choices = GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      )

      @grouped_interviews = Interview.for_application_choices(application_choices)
        .undiscarded
        .includes([:provider, application_choice: [:course_option, application_form: [:candidate]]])
        .where('date_and_time >= ?', Time.zone.now)
        .order(:date_and_time).group_by(&:date)
    end
  end
end
