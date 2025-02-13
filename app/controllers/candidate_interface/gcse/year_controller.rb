module CandidateInterface
  class Gcse::YearController < Gcse::BaseController
    def new
      set_previous_path
      @year_form = CandidateInterface::GcseYearForm.build_from_qualification(current_qualification)
    end

    def edit
      @year_form = CandidateInterface::GcseYearForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @year_form = CandidateInterface::GcseYearForm.new(year_params)

      if @year_form.save(current_qualification)
        if current_qualification.failed_required_gcse?
          redirect_to candidate_interface_gcse_details_edit_grade_explanation_path(subject: @subject)
        else
          redirect_to candidate_interface_gcse_review_path
        end
      else
        set_previous_path
        track_validation_error(@year_form)

        render :new
      end
    end

    def update
      @year_form = CandidateInterface::GcseYearForm.new(year_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @year_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@year_form)

        render :edit
      end
    end

  private

    def year_params
      strip_whitespace params
        .expect(candidate_interface_gcse_year_form: [:award_year])
        .merge!(qualification_type: current_qualification.qualification_type)
    end

    def set_previous_path
      @previous_path = if current_qualification.subject == 'maths'
                         candidate_interface_new_gcse_maths_grade_path(@subject)
                       elsif current_qualification.subject == 'english'
                         candidate_interface_new_gcse_english_grade_path(@subject)
                       else
                         candidate_interface_new_gcse_science_grade_path(@subject)
                       end
    end
  end
end
