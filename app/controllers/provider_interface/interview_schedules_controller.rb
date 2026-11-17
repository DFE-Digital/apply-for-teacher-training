module ProviderInterface
  class InterviewSchedulesController < ProviderInterfaceController
    include Pagy::Backend

    PAGY_PER_PAGE = 50
    def show
      interviews = Interview.for_application_choices(application_choices_for_user_providers)
                            .undiscarded
                            .upcoming
                            .includes([:provider, application_choice: [:current_course, :course_option, application_form: [:candidate]]])
                            .order(:date_and_time)

      @filter = ProviderInterviewFilter.new(
        params: strip_whitespace(params),
        interviews:,
      )

      @pagy, @interviews = pagy(@filter.applied_filters, limit: PAGY_PER_PAGE)
      @grouped_interviews = @interviews.group_by(&:date)
    end

    def past
      interviews = Interview.for_application_choices(application_choices_for_user_providers)
                            .undiscarded
                            .past
                            .includes([:provider, application_choice: [:current_course, :course_option, application_form: [:candidate]]])
                            .order(date_and_time: :desc)

      @filter = ProviderInterviewFilter.new(
        params: strip_whitespace(params),
        interviews:,
      )

      @pagy, @interviews = pagy(@filter.applied_filters, limit: PAGY_PER_PAGE)
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
