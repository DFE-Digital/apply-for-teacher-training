module CandidateInterface
  class Gcse::NewInternationalFlow::FailingGradeInterruptionController < Gcse::NewInternationalFlow::BaseController
    def show
      @return_to = return_to
      @enic_path = enic_path
      @evidence_path = evidence_path
    end

  private

    def return_to
      if from_review?
        candidate_interface_gcse_review_path(@subject)
      else
        candidate_interface_gcse_new_international_flow_new_grades_path
      end
    end

    def enic_path
      if from_review?
        candidate_interface_gcse_new_international_flow_edit_enic_path(@subject)
      else
        candidate_interface_gcse_new_international_flow_new_enic_path(@subject)
      end
    end

    def evidence_path
      if from_review?
        candidate_interface_gcse_new_international_flow_edit_evidence_path(@subject)
      else
        candidate_interface_gcse_new_international_flow_new_evidence_path(@subject)
      end
    end

    def from_review?
      params['return-to'] == 'application-review'
    end
  end
end
