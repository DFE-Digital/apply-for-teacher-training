module CandidateInterface
  class Gcse::GradeExplanationController < Gcse::BaseController
    def edit
      @form = CandidateInterface::GcseGradeExplanationForm.build_from_qualification(current_qualification)
    end

    def update
      @form = CandidateInterface::GcseGradeExplanationForm.new(update_params)

      if @form.save(current_qualification)
        if current_qualification.award_year.nil?
          redirect_to candidate_interface_gcse_details_edit_year_path(subject: params[:subject])
        else
          redirect_to candidate_interface_gcse_review_path
        end
      else
        track_validation_error(@form)

        render :edit
      end
    end

  private

    def update_params
      strip_whitespace params
        .require(:candidate_interface_gcse_grade_explanation_form)
        .permit(:missing_explanation)
    end
  end
end
