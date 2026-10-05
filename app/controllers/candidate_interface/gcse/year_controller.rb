module CandidateInterface
  class Gcse::YearController < Gcse::InternationalBaseController
    def new
      set_previous_path
      @year_form = CandidateInterface::GcseYearForm.build_from_qualification(current_qualification)
    end

    def edit
      @year_form = CandidateInterface::GcseYearForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
    end

    def create
      @year_form = CandidateInterface::GcseYearForm.new(year_params)

      if @year_form.save(current_qualification)
        if current_qualification.qualification_type == 'non_uk'
          redirect_to candidate_interface_gcse_review_path(@subject)
        elsif current_qualification.failed_required_gcse?
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
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

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
      @previous_path = if current_qualification.not_completed_explanation.present?
                         candidate_interface_gcse_new_evidence_path
                       elsif current_qualification.enic_reference.present?
                         x_gcse_new_statement_comparability_path(@subject)
                       else
                         candidate_interface_gcse_details_new_enic_path
                       end
    end
  end
end
