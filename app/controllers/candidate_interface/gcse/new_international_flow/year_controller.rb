module CandidateInterface
  class Gcse::NewInternationalFlow::YearController < Gcse::NewInternationalFlow::BaseController
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
        redirect_to candidate_interface_gcse_review_path
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
      @previous_path = if current_qualification.not_completed_explanation.present?
                         candidate_interface_gcse_new_international_flow_new_evidence_path
                       elsif current_qualification.enic_reference.present?
                         new_international_flow_statement_comparability_path(@subject)
                       else
                         candidate_interface_gcse_new_international_flow_new_enic_path
                       end
    end
  end
end
