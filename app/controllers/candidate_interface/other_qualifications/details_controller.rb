module CandidateInterface
  class OtherQualifications::DetailsController < OtherQualifications::BaseController
    def new
      @wizard = wizard_for(current_step: :details)
      @wizard.qualification_type ||= params[:qualification_type]
      @wizard.initialize_new_qualification(
        current_application.application_qualifications.other.order(:created_at),
      )
      @wizard.save_state!
      set_subject_autocomplete_data
      set_grade_autocomplete_data
    end

    def create
      @wizard = wizard_for(other_qualification_params.merge(current_step: :details))
      @wizard.save_state!
      set_subject_autocomplete_data
      set_grade_autocomplete_data

      if @wizard.valid?(:details)
        commit
        @wizard.clear_state!

        if @wizard.choice == 'same_type'
          redirect_to candidate_interface_new_other_qualification_details_path(qualification_type: current_application.application_qualifications.last.qualification_type)
        elsif @wizard.choice == 'different_type'
          redirect_to candidate_interface_new_other_qualification_type_path
        else
          redirect_to candidate_interface_review_other_qualifications_path
        end
      elsif @wizard.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@wizard)
        render :new
      end
    end

    def edit
      @wizard = wizard_for(
        current_step: :details,
        initialize_from_db: true,
        checking_answers: true,
      )
      @wizard.save_state!
      set_subject_autocomplete_data
      set_grade_autocomplete_data
    end

    def update
      @wizard = wizard_for(
        other_qualification_update_params.merge(current_step: :details, checking_answers: true),
      )
      @wizard.save_state!
      set_subject_autocomplete_data
      set_grade_autocomplete_data

      if @wizard.valid?(:details)
        commit
        current_application.update!(other_qualifications_completed: false)
        @wizard.clear_state!
        redirect_to candidate_interface_review_other_qualifications_path
      elsif @wizard.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@wizard)
        render :edit
      end
    end

  private

    def commit
      application_qualification =
        if params[:id].present?
          current_qualification
        else
          current_application.application_qualifications.build(
            level: ApplicationQualification.levels[:other],
          )
        end

      application_qualification.assign_attributes(@wizard.attributes_for_persistence)
      application_qualification.save!
    end

    def wizard_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      OtherQualificationWizard.new(
        WizardStateStores::RedisStore.new(key: persistence_key_for_current_user),
        options.delete(:initialize_from_db) ? current_qualification : nil,
        options,
      )
    end

    def persistence_key_for_current_user
      "candidate_user_other_qualification_wizard-#{current_candidate.id}"
    end

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_wizard).permit(
        :subject,
        :grade,
        :award_year,
        :choice,
        :institution_country,
        :other_uk_qualification_type,
        :non_uk_qualification_type,
      ).merge!(
        id: params[:id],
      )
    end

    def other_qualification_update_params
      other_qualification_params.merge(
        params.require(:candidate_interface_other_qualification_wizard).permit(:qualification_type),
      )
    end

    def set_subject_autocomplete_data
      qualification_type = @wizard.qualification_type_name
      if qualification_type.in? [OtherQualificationWizard::A_LEVEL_TYPE, OtherQualificationWizard::AS_LEVEL_TYPE]
        @subject_autocomplete_data = A_AND_AS_LEVEL_SUBJECTS
      elsif qualification_type == 'GCSE'
        @subject_autocomplete_data = GCSE_SUBJECTS
      end
    end

    def set_grade_autocomplete_data
      qualification_type = @wizard.qualification_type_name
      if qualification_type.in? OTHER_UK_QUALIFICATIONS
        @grade_autocomplete_data = OTHER_UK_QUALIFICATION_GRADES
      end
    end
  end
end
