module CandidateInterface
  class OtherQualifications::DetailsController < OtherQualifications::BaseController
    def new
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        current_step: :details,
      )

      @form.qualification_type ||= params[:qualification_type]
      @form.initialize_from_last_qualification(
        current_application.application_qualifications.other.order(:created_at),
      )
      set_subject_autosuggest_data
      set_grade_autosuggest_data
      @form.save_intermediate!
    end

    def create
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_params.merge(current_step: :details),
      )

      @form.save_intermediate!
      set_subject_autosuggest_data
      set_grade_autosuggest_data

      if @form.valid?
        @form.save!
        reset_intermediate_state!

        if @form.choice == 'same_type'
          redirect_to candidate_interface_other_qualification_details_path(qualification_type: current_application.application_qualifications.last.qualification_type)
        elsif @form.choice == 'different_type'
          redirect_to candidate_interface_other_qualification_type_path
        else
          redirect_to candidate_interface_review_other_qualifications_path
        end
      elsif @form.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@form)
        render :new
      end
    end

    def edit
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        id: params[:id],
        current_step: :details,
        editing: true,
      )

      @form.save_intermediate!
      set_subject_autosuggest_data
      set_grade_autosuggest_data
    end

    def update
      @form = OtherQualificationDetailsForm.new(
        current_application,
        intermediate_data_service,
        other_qualification_update_params.merge(
          id: params[:id],
          current_step: :details,
          editing: true,
        ),
      )

      @form.save_intermediate!
      set_subject_autosuggest_data
      set_grade_autosuggest_data

      if @form.valid?
        @form.save!
        current_application.update!(other_qualifications_completed: false)
        reset_intermediate_state!
        redirect_to candidate_interface_review_other_qualifications_path
      elsif @form.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@form)
        render :edit
      end
    end

  private

    def other_qualification_params
      strip_whitespace params
        .require(:candidate_interface_other_qualification_details_form).permit(
          :subject,
          :grade,
          :award_year,
          :choice,
          :institution_country,
          :other_uk_qualification_type,
          :non_uk_qualification_type,
        )
        .merge!(id: params[:id])
    end

    def other_qualification_update_params
      other_qualification_params.merge(
        strip_whitespace(
          params
          .require(:candidate_interface_other_qualification_details_form)
          .permit(:qualification_type),
        ),
      )
    end

    def set_subject_autosuggest_data
      qualification_type = @form.qualification_type_name
      if qualification_type.in? [OtherQualificationTypeForm::A_LEVEL_TYPE, OtherQualificationTypeForm::AS_LEVEL_TYPE]
        @subjects = A_AND_AS_LEVEL_SUBJECTS
      elsif qualification_type == 'GCSE'
        @subjects = GCSE_SUBJECTS
      end
    end

    def set_grade_autosuggest_data
      if @form.qualification_type == 'Other'
        @grades = OTHER_UK_QUALIFICATION_GRADES
      end
    end
  end
end
