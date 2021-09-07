module CandidateInterface
  class Gcse::GradeExplanationController < Gcse::BaseController
    def new
      set_previous_path
      @form = CandidateInterface::GcseGradeExplanationForm.build_from_qualification(current_qualification)
    end

    def create
      @form = CandidateInterface::GcseGradeExplanationForm.new(update_params)

      if @form.save(current_qualification)
        if update_params[:not_completed_explanation] == 'No'
          redirect_to candidate_interface_gcse_missing_path
        else
          redirect_to candidate_interface_gcse_details_new_year_path(params[:subject])
        end
      else
        set_previous_path
        track_validation_error(@form)

        render :new
      end
    end

    def edit
      @form = CandidateInterface::GcseGradeExplanationForm.build_from_qualification(current_qualification)
    end

    def update
      @form = CandidateInterface::GcseGradeExplanationForm.new(update_params)

      if @form.save(current_qualification)
        if update_params[:not_completed_explanation] == 'No'
          redirect_to candidate_interface_gcse_missing_path
        else
          redirect_to candidate_interface_gcse_review_path
        end
      else
        track_validation_error(@form)

        render :edit
      end
    end

  private

    def set_previous_path
      @previous_path = if current_qualification.subject == 'maths'
                         candidate_interface_new_gcse_maths_grade_path
                       elsif current_qualification.subject == 'english'
                         candidate_interface_new_gcse_english_grade_path
                       else
                         candidate_interface_new_gcse_science_grade_path
                       end
    end

    def update_params
      strip_whitespace params
        .require(:candidate_interface_gcse_grade_explanation_form)
<<<<<<< HEAD
        .permit(:not_completed_explanation)
=======
        .permit(:missing_explanation, :not_completed_explanation)
>>>>>>> a3fb75281 (Update existing grade explanation form for new flow)
    end
  end
end
