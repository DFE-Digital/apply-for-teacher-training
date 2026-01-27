module CandidateInterface
  class Gcse::GradeExplanationController < Gcse::BaseController
    def new
      set_previous_path
      @form = GcseGradeExplanationForm.build_from_qualification(current_qualification)
    end

    def edit
      @form = GcseGradeExplanationForm.build_from_qualification(current_qualification)
    end

    def create
      @form = GcseGradeExplanationForm.new(grade_explanation_params)

      if @form.save(current_qualification)
        if @form.currently_completing_qualification == false
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

    def update
      @form = GcseGradeExplanationForm.new(grade_explanation_params)

      if @form.save(current_qualification)
        if @form.currently_completing_qualification == false
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

    def grade_explanation_params
      return {} if params[:candidate_interface_gcse_grade_explanation_form].blank?

      strip_whitespace params
        .expect(candidate_interface_gcse_grade_explanation_form: %i[currently_completing_qualification missing_explanation])
    end
  end
end
