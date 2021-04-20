module SupportInterface
  class CandidateFeedbackExport
    def data_for_export
      application_forms.find_each(batch_size: 100).map do |application_form|
        {
          full_name: application_form.full_name,
          recruitment_cycle_year: application_form.recruitment_cycle_year,
          email: application_form.candidate.email_address,
          phone_number: application_form.phone_number,
          submitted_at: application_form.submitted_at&.iso8601,
          satisfaction_level: application_form.feedback_satisfaction_level,
          csat_score: csat_score(application_form.feedback_satisfaction_level),
          suggestions: application_form.feedback_suggestions,
        }
      end
    end

  private

    def application_forms
      @application_forms ||= ApplicationForm.where.not(
        feedback_satisfaction_level: nil,
      ).includes(:candidate)
    end

    CSAT_SCORES = {
      very_satisfied: 5,
      satisfied: 4,
      neither_satisfied_or_dissatisfied: 3,
      dissatisfied: 2,
      very_dissatisfied: 1,
    }.with_indifferent_access.freeze

    def csat_score(satisfaction_level)
      CSAT_SCORES[satisfaction_level]
    end
  end
end
