module CandidateAPI
  module Serializers
    class V11 < Base
      def query
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_1_deadline(RecruitmentCycle.previous_year)))
        .distinct
        .includes(application_forms: :application_choices)
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end
    end
  end
end
