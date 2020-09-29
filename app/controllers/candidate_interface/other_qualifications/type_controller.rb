module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
      @wizard = wizard_for(current_step: :type)
      @qualification_type = @wizard.qualification_type_form
    end

    def create
      @wizard = wizard_for(other_qualification_type_params.merge(current_step: :type))
      @qualification_type = @wizard.qualification_type_form

      if @wizard.valid?(:type)
        @wizard.save_state!

        next_step = @wizard.next_step

        if next_step.first == :details
          redirect_to candidate_interface_new_other_qualification_details_path
        else
          track_validation_error(@qualification_type)
          render :new
        end
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def edit
      @qualification_type = OtherQualificationTypeForm.build_from_qualification(current_qualification)
    end

    def update
      @qualification_type = OtherQualificationTypeForm.new(other_qualification_type_params)

      if qualification_type_has_changed && @qualification_type.update(current_qualification)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_edit_other_qualification_details_path(current_qualification)
      elsif @qualification_type.update(current_qualification)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification_type)
        render :edit
      end
    end

  private

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      OtherQualificationWizard.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
        options,
      )
    end

    def persistence_key_for_current_user
      "candidate_user_other_qualification_wizard-#{current_candidate.id}"
    end

    def other_qualification_type_params
      params.fetch(:candidate_interface_other_qualification_type_form, {}).permit(
        :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
      )
    end

    def qualification_type_has_changed
      @qualification_type.qualification_type != current_qualification.qualification_type
    end
  end
end
