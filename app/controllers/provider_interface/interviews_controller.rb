module ProviderInterface
  class InterviewsController < ProviderInterfaceController
    include ClearWizardCache

    before_action :set_application_choice, :set_workflow_flags
    before_action :requires_set_up_interviews_permission, except: %i[index]
    before_action :confirm_application_is_in_decision_pending_state, except: %i[index]
    before_action :confirm_interview_is_not_in_the_past, only: %i[edit update destroy]
    before_action :redirect_to_index_if_store_cleared, only: %i[create]
    before_action :redirect_to_index_if_edit_store_cleared, only: %i[update]
    before_action :redirect_to_index_if_cancel_store_cleared, only: %i[destroy]

    def index
      application_at_interviewable_stage = ApplicationStateChange::INTERVIEWABLE_STATES.include?(
        @application_choice.status.to_sym,
      )
      @interviews_can_be_created_and_edited = application_at_interviewable_stage && @provider_user_can_set_up_interviews

      redirect_to provider_interface_application_choice_path if @application_choice.interviews.none?
    end

    def new
      clear_wizard_if_new_entry(InterviewWizard.new(interview_store, {}))

      @wizard = InterviewWizard.new(interview_store, interview_form_context_params.merge(current_step: 'input', action:))
      @wizard.referer ||= request.referer
      @wizard.save_state!
    end

    def edit
      clear_wizard_if_new_entry(InterviewWizard.new(edit_interview_store(interview_id), {}))

      @wizard = InterviewWizard.from_model(edit_interview_store(interview_id), interview, 'edit', action)
      @wizard.referer ||= request.referer
      @wizard.save_state!
    end

    def create
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
        track_validation_error(@wizard)
        render :new
      end
    end

    def update
      @interview = @application_choice.interviews.find(interview_id)
      @wizard = InterviewWizard.new(edit_interview_store(interview_id), interview_form_context_params)

      if @wizard.valid?
        UpdateInterview.new(
          actor: current_provider_user,
          interview: @interview,
          provider: @wizard.provider,
          date_and_time: @wizard.date_and_time,
          location: @wizard.location,
          additional_details: @wizard.additional_details,
        ).save!

        @wizard.clear_state!

        flash[:success] = t('.success')
        redirect_to provider_interface_application_choice_interviews_path(@application_choice)
      else
        track_validation_error(@wizard)
        render :edit
      end
    end

    def destroy
      @wizard = CancelInterviewWizard.new(cancel_interview_store(interview_id))

      CancelInterview.new(
        actor: current_provider_user,
        application_choice: @application_choice,
        interview:,
        cancellation_reason: @wizard.cancellation_reason,
      ).save!

      @wizard.clear_state!

      flash[:success] = t('.success')
      redirect_to provider_interface_application_choice_path(@application_choice)
    end

  private

    def interview_form_context_params
      {
        application_choice: @application_choice,
        provider_user: current_provider_user,
      }
    end

    def interview_params
      params
        .expect(provider_interface_interview_wizard: %i[date time location additional_details provider_id])
        .transform_values(&:strip)
        .merge(interview_form_context_params)
    end

    def interview
      @interview ||= @application_choice.interviews.find(interview_id)
    end

    def interview_store
      key = "interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def edit_interview_store(interview_id)
      key = "interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}_#{interview_id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def cancel_interview_store(interview_id)
      key = "cancel_interview_wizard_store_#{current_provider_user.id}_#{@application_choice.id}_#{interview_id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def confirm_application_is_in_decision_pending_state
      return if @application_choice.decision_pending?

      redirect_back_or_to(provider_interface_application_choice_path(@application_choice))
    end

    def confirm_interview_is_not_in_the_past
      return if interview.date_and_time >= Time.zone.now.beginning_of_day

      flash[:warning] = t('activemodel.errors.models.interview_workflow_constraints.attributes.changing_a_past_interview')
      redirect_to provider_interface_application_choice_interviews_path(@application_choice)
    end

    def redirect_to_index_if_store_cleared
      redirect_to provider_interface_application_choice_interviews_path(@application_choice) if interview_store.read.blank?
    end

    def redirect_to_index_if_edit_store_cleared
      return if edit_interview_store(interview_id).read.present?

      redirect_to provider_interface_application_choice_interviews_path(@application_choice)
    end

    def redirect_to_index_if_cancel_store_cleared
      return if cancel_interview_store(interview_id).read.present?

      redirect_to provider_interface_application_choice_interviews_path(@application_choice)
    end

    def interview_id
      params.permit(:id)[:id]
    end

    def action
      'back' if !!params[:back]
    end

    def wizard_controller_excluded_paths
      [provider_interface_application_choice_interviews_path]
    end

    def wizard_flow_controllers
      ['provider_interface/interviews', 'provider_interface/interviews/checks'].freeze
    end
  end
end
