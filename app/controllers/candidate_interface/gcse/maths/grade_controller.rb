module CandidateInterface
  class Gcse::Maths::GradeController < Gcse::BaseController
    def edit
      @gcse_grade_form = MathsGcseGradeForm.build_from_qualification(current_qualification)
      @qualification_type = @gcse_grade_form.qualification_type
    end

    def update
      @gcse_grade_form = MathsGcseGradeForm.new(maths_params)

      if @gcse_grade_form.save(current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
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

    def next_gcse_path
      if current_qualification.award_year.nil?
        candidate_interface_gcse_details_edit_year_path(subject: @subject)
      else
        candidate_interface_gcse_review_path(subject: @subject)
      end
    end

    def maths_params
      strip_whitespace params
                        .require(:candidate_interface_maths_gcse_grade_form)
                        .permit(%i[grade award_year other_grade])
                        .merge!(qualification_type: current_qualification.qualification_type)
    end
  end
end
