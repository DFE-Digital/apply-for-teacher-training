module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
      reset_wizard_state!
      @wizard = wizard_for(current_step: :type)
    end

    def create
      @wizard = wizard_for(other_qualification_type_params.merge(current_step: :type))

      if @wizard.valid?(:type)
        @wizard.save_state!

        next_step = @wizard.next_step

        if next_step.first == :details
          redirect_to candidate_interface_new_other_qualification_details_path
        else
          track_validation_error(@wizard)
          render :new
        end
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def edit
      @wizard = wizard_for(current_step: :type)
      @wizard.copy_attributes(current_qualification)
      @wizard.save_state!
    end

    def update
      @wizard = wizard_for(
        other_qualification_type_params.merge(
          current_step: :type,
          checking_answers: true,
          id: current_qualification.id,
        ),
      )
      if @wizard.valid?(:type)
        @wizard.save_state!

        next_step = @wizard.next_step

        if next_step.first == :details
          redirect_to candidate_interface_edit_other_qualification_details_path(current_qualification.id)
        elsif next_step.first == :check
          current_application.update!(other_qualifications_completed: false)
          commit
          @wizard.clear_state!
          redirect_to candidate_interface_review_other_qualifications_path
        else
          render :edit
        end
      else
        track_validation_error(@wizard)
        render :edit
      end
    end

  private

    def commit
      current_qualification.update!(@wizard.attributes_for_persistence)
    end

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      OtherQualificationWizard.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
        nil,
        options,
      )
    end

    def reset_wizard_state!
      OtherQualificationWizard.clear_state!(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
      )
    end

    def persistence_key_for_current_user
      "candidate_user_other_qualification_wizard-#{current_candidate.id}"
    end

    def other_qualification_type_params
      params.fetch(:candidate_interface_other_qualification_wizard, {}).permit(
        :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
      )
    end
  end
end
