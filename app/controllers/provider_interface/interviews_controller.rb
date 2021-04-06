module ProviderInterface
  class InterviewsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :interview_flag_enabled?
    before_action :requires_make_decisions_permission, except: %i[index]
    before_action :confirm_application_is_in_decision_pending_state, except: %i[index]
    before_action :redirect_to_index_if_store_cleared, only: %i[check commit]

    def index
      application_at_interviewable_stage = ApplicationStateChange::INTERVIEWABLE_STATES.include?(
        @application_choice.status.to_sym,
      )
      @provider_can_make_decisions = current_provider_user.authorisation.can_make_decisions?(
        application_choice: @application_choice,
        course_option_id: @application_choice.current_course_option.id,
      )
      @interviews_can_be_created_and_edited = application_at_interviewable_stage && @provider_can_make_decisions

      redirect_to provider_interface_application_choice_path if @application_choice.interviews.none?
    end

    def new
      @wizard = InterviewWizard.new(interview_store, interview_form_context_params.merge(current_step: 'input'))
      @wizard.save_state!
    end

    def edit
      @interview = @application_choice.interviews.find(params[:id])

      @wizard = InterviewWizard.from_model(interview_store, @interview, 'input')
      @wizard.save_state!
    end

    def check
      if params[:id]
        @interview = @application_choice.interviews.find(params[:id])
        @translation_prefix = '.update'
      end

      @wizard = InterviewWizard.new(interview_store, interview_params.merge(current_step: 'check'))
      @wizard.save_state!
      render :new unless @wizard.valid?
    end

    def commit
      @wizard = InterviewWizard.new(interview_store, interview_form_context_params)

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

        flash[:success] = t('.success')
        redirect_to provider_interface_application_choice_interviews_path(@application_choice)
      else
        render :check
      end
    end

    def update
      interview = @application_choice.interviews.find(params[:id])
      @wizard = InterviewWizard.new(interview_store, interview_form_context_params)

      if @wizard.valid?
        UpdateInterview.new(
          actor: current_provider_user,
          interview: interview,
          provider: @wizard.provider,
          date_and_time: @wizard.date_and_time,
          location: @wizard.location,
          additional_details: @wizard.additional_details,
        ).save!

        @wizard.clear_state!

        flash[:success] = t('.success')
        redirect_to provider_interface_application_choice_interviews_path(@application_choice)
      else
        render :check
      end
    end

    def cancel
      @interview = @application_choice.interviews.find(params[:id])
      @cancellation_wizard = CancelInterviewWizard.new(cancel_interview_store)
      @cancellation_wizard.save_state!
    end

    def review_cancel
      @interview = @application_choice.interviews.find(params[:id])

      @cancellation_wizard = CancelInterviewWizard.new(cancel_interview_store, cancellation_params)
      @cancellation_wizard.save_state!

      render :cancel unless @cancellation_wizard.valid?
    end

    def confirm_cancel
      @interview = @application_choice.interviews.find(params[:id])
      @cancellation_wizard = CancelInterviewWizard.new(cancel_interview_store)

      CancelInterview.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        interview: @interview,
        cancellation_reason: @cancellation_wizard.cancellation_reason,
      ).save!

      @cancellation_wizard.clear_state!

      flash[:success] = t('.success')
      redirect_to provider_interface_application_choice_path(@application_choice)
    end

  private

    def cancellation_params
      params.require(:provider_interface_cancel_interview_wizard).permit(:cancellation_reason)
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

    def interview_store
      key = "interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def cancel_interview_store
      key = "cancel_interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def confirm_application_is_in_decision_pending_state
      return if @application_choice.decision_pending?

      redirect_back(fallback_location: provider_interface_application_choice_path(@application_choice))
    end

    def redirect_to_index_if_store_cleared
      redirect_to provider_interface_application_choice_interviews_path(@application_choice) if interview_store.read.blank?
    end
  end
end
