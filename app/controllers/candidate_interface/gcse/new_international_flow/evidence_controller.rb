module CandidateInterface
  class Gcse::NewInternationalFlow::EvidenceController < Gcse::NewInternationalFlow::BaseController
    def new
      @evidence_form = GcseInternationalEvidenceForm.build_from_qualification(current_qualification)
    end

    def edit
      @evidence_form = GcseInternationalEvidenceForm.build_from_qualification(current_qualification)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)
    end

    def create
      @evidence_form = GcseInternationalEvidenceForm.new(evidence_params)

      if @evidence_form.save(current_qualification)
        redirect_to candidate_interface_gcse_details_new_year_path
      else
        track_validation_error(@evidence_form)
        render :new
      end
    end

    def update
      @evidence_form = GcseInternationalEvidenceForm.new(evidence_params)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path)

      if @evidence_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@evidence)
        render :edit
      end
    end

  private

    def evidence_params
      params
        .expect(candidate_interface_gcse_international_evidence_form: %i[evidence])
    end
  end
end
