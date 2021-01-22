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
      @wizard = InterviewWizard.new(store, interview_form_context_params.merge(current_step: 'input'))
      @wizard.save_state!
    end

    def check
      @wizard = InterviewWizard.new(store, interview_params.merge(current_step: 'check'))
      @wizard.save_state!
      render :new unless @wizard.valid?
    end

    def commit
      @wizard = InterviewWizard.new(store, interview_form_context_params)

      if @wizard.valid?
        CreateInterview.new(
          actor: current_provider_user,
          application_choice: @application_choice,
          provider: @wizard.provider,
          date_and_time: @wizard.date_and_time,
          location: @wizard.location,
          additional_details: @wizard.additional_details,
        ).save!
        @wizard.clear_state!

        flash[:success] = 'Interview set up'
        redirect_to provider_interface_application_choice_interviews_path(@application_choice)
      else
        render :check
      end
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

    def interview_form_context_params
      {
        application_choice: @application_choice,
        provider_user: current_provider_user,
      }
    end

    def interview_params
      params
        .require(:provider_interface_interview_wizard)
        .permit(:date, :time, :location, :additional_details, :provider_id)
        .transform_values(&:strip)
        .merge(interview_form_context_params)
    end

    def store
      key = "interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end
