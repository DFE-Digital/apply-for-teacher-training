module CandidateInterface
  class Gcse::Maths::GradeController < Gcse::BaseController
    def new
      @gcse_grade_form = MathsGcseGradeForm.build_from_qualification(current_qualification)
      @qualification_type = @gcse_grade_form.qualification_type
      set_previous_path
    end

    def create
      @gcse_grade_form = MathsGcseGradeForm.new(maths_params)

      if @gcse_grade_form.save(current_qualification)
        if current_qualification.failed_required_gcse?
          redirect_to candidate_interface_gcse_details_new_grade_explanation_path(subject: @subject)
        else
          redirect_to candidate_interface_gcse_details_new_year_path(subject: @subject)
        end
      else
        @qualification_type = @gcse_grade_form.qualification_type
        set_previous_path
        track_validation_error(@gcse_grade_form)

        render :new
      end
    end

    def edit
      @gcse_grade_form = MathsGcseGradeForm.build_from_qualification(current_qualification)
      @qualification_type = @gcse_grade_form.qualification_type
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
    end

    def update
      @gcse_grade_form = MathsGcseGradeForm.new(maths_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @gcse_grade_form.save(current_qualification)
        return redirect_to candidate_interface_application_review_path if redirect_back_to_application_review_page?

        if current_qualification.failed_required_gcse?
          redirect_to candidate_interface_gcse_details_edit_grade_explanation_path(subject: @subject)
        else
          redirect_to candidate_interface_gcse_review_path(subject: @subject)
        end
      else
        @qualification_type = @gcse_grade_form.qualification_type
        track_validation_error(@gcse_grade_form)

        render :edit
      end
    end

  private

    def set_subject
      @subject = 'maths'
    end

    def maths_params
      strip_whitespace params
                        .require(:candidate_interface_maths_gcse_grade_form)
                        .permit(%i[grade award_year other_grade])
                        .merge!(qualification_type: current_qualification.qualification_type)
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
