module ProviderInterface
  class ReasonsForRejectionController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :redirect_if_application_rejected_and_feedback_provided
    before_action :ensure_structured_reasons_for_rejection_on_rbd_feature_is_active

    def edit_initial_questions
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'initial_questions')
      @wizard.save_state!
    end

    def update_initial_questions
      @wizard = ReasonsForRejectionWizard.new(store, reasons_for_rejection_params.merge(current_step: 'initial_questions'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_initial_questions
      end
    end

    def edit_other_reasons
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'other_reasons')
      @wizard.save_state!
    end

    def update_other_reasons
      @wizard = ReasonsForRejectionWizard.new(store, reasons_for_rejection_params.merge(current_step: 'other_reasons'))

      if @wizard.valid_for_current_step?
        @wizard.save_state!
        redirect_to next_redirect(@wizard)
      else
        render :edit_other_reasons
      end
    end

    def check
      @wizard = ReasonsForRejectionWizard.new(store, current_step: 'check')
      @back_link_path = if @wizard.needs_other_reasons?
                          provider_interface_reasons_for_rejection_other_reasons_path(@application_choice)
                        else
                          provider_interface_reasons_for_rejection_initial_questions_path(@application_choice)
                        end

      @wizard.save_state!
    end

    def commit
      @wizard = ReasonsForRejectionWizard.new(store)

      if rbd_application_with_no_feedback?
        service = RejectByDefaultFeedback.new(actor: current_provider_user, application_choice: @application_choice, structured_rejection_reasons: @wizard.to_model)
        success_message = 'Feedback sent'
      else
        service = RejectApplication.new(actor: current_provider_user, application_choice: @application_choice, structured_rejection_reasons: @wizard.to_model)
        success_message = 'Application rejected'
      end

      if service.save
        @wizard.clear_state!
        OfferWizard.new(offer_store).clear_state!

        flash[:success] = success_message
        redirect_to provider_interface_application_choice_feedback_path(@application_choice)
      else
        @wizard.errors.merge!(service.errors)
        render :check
      end
    end

    def next_redirect(wizard)
      {
        'other_reasons' => { action: :edit_other_reasons },
        'check' => { action: :check },
      }.fetch(wizard.next_step)
    end

    def reasons_for_rejection_params
      params.require(:reasons_for_rejection)
        .permit(:candidate_behaviour_y_n, :candidate_behaviour_other,
                :candidate_behaviour_what_to_improve,
                :quality_of_application_y_n, :quality_of_application_personal_statement_what_to_improve,
                :quality_of_application_subject_knowledge_what_to_improve,
                :quality_of_application_other_details, :quality_of_application_other_what_to_improve,
                :qualifications_y_n, :qualifications_other_details,
                :performance_at_interview_y_n, :performance_at_interview_what_to_improve,
                :course_full_y_n,
                :offered_on_another_course_y_n,
                :offered_on_another_course_details,
                :honesty_and_professionalism_y_n,
                :honesty_and_professionalism_concerns_plagiarism_details,
                :honesty_and_professionalism_concerns_information_false_or_inaccurate_details,
                :honesty_and_professionalism_concerns_references_details,
                :honesty_and_professionalism_concerns_other_details,
                :safeguarding_y_n,
                :safeguarding_concerns_candidate_disclosed_information_details,
                :safeguarding_concerns_vetting_disclosed_information_details,
                :safeguarding_concerns_other_details,
                :other_advice_or_feedback_y_n,
                :other_advice_or_feedback_details,
                :why_are_you_rejecting_this_application,
                honesty_and_professionalism_concerns: [],
                safeguarding_concerns: [],
                qualifications_which_qualifications: [],
                quality_of_application_which_parts_needed_improvement: [],
                candidate_behaviour_what_did_the_candidate_do: [])
    end

    def store
      key = "reasons_for_rejection_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def redirect_if_application_rejected_and_feedback_provided
      if @application_choice&.rejected? && !@application_choice.no_feedback?
        if @application_choice.rejected_by_default?
          flash[:warning] = 'The feedback for this application has already been provided.'
        else
          flash[:warning] = 'This application has already been rejected.'
        end

        redirect_to provider_interface_application_choice_feedback_path(@application_choice)
      end
    end

    def ensure_structured_reasons_for_rejection_on_rbd_feature_is_active
      render_404 if rbd_application_with_no_feedback? && !FeatureFlag.active?(:structured_reasons_for_rejection_on_rbd)
    end

  private

    def rbd_application_with_no_feedback?
      @application_choice.rejected_by_default? && @application_choice.no_feedback?
    end

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end
