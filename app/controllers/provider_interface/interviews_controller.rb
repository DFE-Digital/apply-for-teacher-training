module ProviderInterface
  class InterviewsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :interview_flag_enabled?
    before_action :requires_make_decisions_permission

    def index
      @provider_can_respond = current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.offered_option.id,
      )

      @interviews = @application_choice.interviews.kept.includes([:provider])
    end

    def new
      # TODO: Remove once the user is able to create new interviews
      # Workaround creating interviews until the interview form is in place.
      # In order to create new interviews amend the 'Setup interview button' url to include a date parameter
      # You can optionally specify a location and additional details as well
      # e.g. ..../interviews/new to .../interviews/new?date_and_time=2021-2-5
      #
      date_and_time = params[:date_and_time]&.to_date
      if date_and_time.blank?
        flash['info'] = 'Interview creation is not available yet'
        redirect_back(fallback_location: provider_interface_application_choice_path(@application_choice)) and return
      end

      CreateInterview.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        provider: @application_choice.offered_course.provider,
        date_and_time: date_and_time,
        location: params[:location],
        additional_details: params[:additional_details],
      ).save!

      flash['success'] = 'Interview successfully created'
      redirect_to provider_interface_application_choice_interviews_path(@application_choice)
    end

    def cancel
      @interview = @application_choice.interviews.find(params[:id])
    end

    def review_cancel
      @interview = @application_choice.interviews.find(params[:id])
      @interview.cancellation_reason = cancellation_reason
    end

    def confirm_cancel
      @interview = @application_choice.interviews.find(params[:id])
      @interview.cancellation_reason = cancellation_reason

      CancelInterview.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        interview: @interview,
        cancellation_reason: cancellation_reason,
      ).save!

      flash['success'] = 'Interview cancelled'
      redirect_to provider_interface_application_choice_path(@application_choice)
    end

  private

    def cancellation_reason
      params.require(:interview).permit(:cancellation_reason)[:cancellation_reason]
    end

    def interview_flag_enabled?
      unless FeatureFlag.active?(:interviews)
        fallback_path = provider_interface_application_choice_path(@application_choice)
        redirect_back(fallback_location: fallback_path)
      end
    end
  end
end
