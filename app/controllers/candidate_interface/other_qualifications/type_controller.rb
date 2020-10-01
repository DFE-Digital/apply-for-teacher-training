module CandidateInterface
  class OtherQualifications::TypeController < OtherQualifications::BaseController
    def new
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
      @wizard.copy_attributes(get_qualification)
      @wizard.save_state!
    end

    def update
      @qualification = ApplicationQualification.find(params[:id])
      @wizard = wizard_for(
        other_qualification_type_params.merge(current_step: :type, checking_answers: true),
      )
      if @wizard.valid?(:type)
        @wizard.save_state!
        # TODO: current_application.update!(other_qualifications_completed: false)
        commit

        next_step = @wizard.next_step

        if next_step.first == :details
          redirect_to candidate_interface_edit_other_qualification_details_path(@qualification.id)
        elsif next_step.first == :check
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
      application_qualification = get_qualification
      application_qualification.update!(@wizard.attributes_for_persistence)
    end

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
      params.fetch(:candidate_interface_other_qualification_wizard, {}).permit(
        :qualification_type, :other_uk_qualification_type, :non_uk_qualification_type
      )
    end

    def qualification_type_has_changed
      @qualification_type.qualification_type != current_qualification.qualification_type
    end

    def get_qualification
      return nil unless params[:id]

      @get_qualification ||= current_application.application_qualifications.other.find(params[:id])
    end
  end
end
