module CandidateInterface
  class Gcse::NewInternationalFlow::EvidenceController < Gcse::NewInternationalFlow::BaseController
    before_action :set_back_path

    def new
      @evidence_form = GcseInternationalEvidenceForm.build_from_qualification(current_qualification, subject: @subject)
    end

    def edit
      @evidence_form = GcseInternationalEvidenceForm.build_from_qualification(current_qualification, subject: @subject)
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))
    end

    def create
      @evidence_form = GcseInternationalEvidenceForm.new(evidence_params.merge(subject: @subject))

      if @evidence_form.save(current_qualification)
        redirect_to candidate_interface_gcse_new_international_flow_new_year_path
      else
        track_validation_error(@evidence_form)
        render :new
      end
    end

    def update
      @evidence_form = GcseInternationalEvidenceForm.new(evidence_params.merge(subject: @subject))
      @return_to = return_to_after_edit(default: candidate_interface_gcse_review_path(@subject))

      if @evidence_form.save(current_qualification)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@evidence)
        render :edit
      end
    end

  private

    def set_back_path
      @back_path =
        if params['return-to'] == 'application-review'
          candidate_interface_gcse_review_path(@subject)
        else
          candidate_interface_gcse_new_international_flow_interruption_path(@subject, 'return-to': 'application-review')
        end
    end

    def evidence_params
      params
        .expect(candidate_interface_gcse_international_evidence_form: %i[evidence])
    end
  end
end
