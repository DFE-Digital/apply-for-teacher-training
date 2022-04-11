module CandidateAPI
  module Serializers
    class V11
      attr_reader :updated_since

      def initialize(updated_since:)
        @updated_since = updated_since
      end

      def serialize(candidates)
        candidates.map do |candidate|
          {
            id: candidate.public_id,
            type: 'candidate',
            attributes: {
              created_at: candidate.created_at.iso8601,
              updated_at: candidate.candidate_api_updated_at,
              email_address: candidate.email_address,
              application_forms:
                candidate.application_forms.order(:created_at).map do |application|
                  {
                    id: application.id,
                    created_at: application.created_at.iso8601,
                    updated_at: application.updated_at.iso8601,
                    application_status: ProcessState.new(application).state,
                    application_phase: application.phase,
                    recruitment_cycle_year: application.recruitment_cycle_year,
                    submitted_at: application.submitted_at&.iso8601,
                  }
                end,
            },
          }
        end
      end

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
