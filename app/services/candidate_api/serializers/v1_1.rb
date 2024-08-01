module CandidateAPI
  module Serializers
    class V11 < Base
      def index_query(updated_since:)
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
        .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_deadline(RecruitmentCycle.previous_year)))
        .distinct
        .includes(application_forms: :application_choices)
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end

      def find_query(candidate_id:)
        Candidate
          .left_outer_joins(:application_forms)
          .where(application_forms: { recruitment_cycle_year: RecruitmentCycle.current_year })
          .or(Candidate.where('candidates.created_at > ? ', CycleTimetable.apply_deadline(RecruitmentCycle.previous_year)))
          .includes(application_forms: :application_choices)
          .find(candidate_id)
      end
    end
  end
end
