module CandidateInterface
  class Gcse::Science::GradeController < Gcse::BaseController
    def new
      @gcse_grade_form = science_gcse_grade_form
      @qualification_type = current_qualification.qualification_type
      set_previous_path

      render view_path
    end

    def create
      @gcse_grade_form = science_gcse_grade_form.assign_values(science_details_params)

      if @gcse_grade_form.save
        if current_qualification.failed_required_gcse?
          redirect_to candidate_interface_gcse_details_new_grade_explanation_path(@subject)
        else
          redirect_to candidate_interface_gcse_details_new_year_path(@subject)
        end
      else
        set_previous_path
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

    def edit
      @gcse_grade_form = science_gcse_grade_form
      @qualification_type = current_qualification.qualification_type
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      render view_path
    end

    def update
      @gcse_grade_form = science_gcse_grade_form.assign_values(science_details_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @gcse_grade_form.save
        return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?

        if current_qualification.failed_required_gcse?
          candidate_interface_gcse_details_edit_grade_explanation_path(@subject)
        else
          candidate_interface_gcse_review_path(@subject)
        end
      else
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

  private

    def view_path
      if gcse_qualification? && current_qualification.award_year.nil?
        'candidate_interface/gcse/science/grade/awards_new'
      elsif gcse_qualification?
        'candidate_interface/gcse/science/grade/awards_edit'
      elsif current_qualification.award_year.nil?
        'candidate_interface/gcse/science/grade/new'
      else
        'candidate_interface/gcse/science/grade/edit'
      end
    end

    def gcse_qualification?
      current_qualification.qualification_type == 'gcse'
    end

    def set_subject
      @subject = ApplicationQualification::SCIENCE
    end

    def science_details_params
      strip_whitespace params
        .require(:candidate_interface_science_gcse_grade_form)
        .permit(%i[gcse_science grade single_award_grade double_award_grade biology_grade chemistry_grade physics_grade])
    end

    def science_gcse_grade_form
      @science_gcse_grade_form ||= ScienceGcseGradeForm.build_from_qualification(current_qualification)
    end

    def set_previous_path
      @previous_path = if current_qualification.non_uk_qualification_type.present?
                         candidate_interface_gcse_details_new_enic_path(@subject)
                       else
                         candidate_interface_gcse_details_new_type_path(@subject)
                       end
    end
  end
end
