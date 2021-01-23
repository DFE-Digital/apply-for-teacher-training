module SupportInterface
  class ReasonsForRejectionController < SupportInterfaceController
    # TODO: move this
    MAPPING = {
      candidate_behaviour_what_did_the_candidate_do: :candidate_behaviour_what_did_the_candidate_do,
      quality_of_application_which_parts_needed_improvement: :quality_of_application,
      qualifications_which_qualifications: :qualifications_which_qualifications,
      honesty_and_professionalism_concerns: :honesty_and_professionalism,
      safeguarding_concerns: :safeguarding_issues,
    }.with_indifferent_access
    
    def sub_reasons
      @reasons = ReasonsForRejectionCountQuery.new.sub_reason_counts
    end
  end
end
