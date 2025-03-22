module CandidateAPI
  module Serializers
    class V11 < Base
      def index_query(updated_since:)
        Candidate
        .left_outer_joins(:application_forms)
        .where(application_forms: { recruitment_cycle_year: current_timetable.recruitment_cycle_year })
        .or(Candidate.where('candidates.created_at > ? ', previous_timetable.apply_deadline_at))
        .distinct
        .includes(application_forms: :application_choices)
        .where('candidate_api_updated_at > ?', updated_since)
        .order('candidates.candidate_api_updated_at DESC')
      end

      def find_query(candidate_id:)
        Candidate
          .left_outer_joins(:application_forms)
          .where(application_forms: { recruitment_cycle_year: current_timetable.recruitment_cycle_year })
          .or(Candidate.where('candidates.created_at > ? ', previous_timetable.apply_deadline_at))
          .includes(application_forms: :application_choices)
          .find(candidate_id)
      end

      def current_timetable
        @current_timetable ||= RecruitmentCycleTimetable.current_timetable
      end

      def previous_timetable
        @previous_timetable ||= RecruitmentCycleTimetable.previous_timetable
      end
    end
  end
end
