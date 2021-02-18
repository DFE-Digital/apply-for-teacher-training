module SupportInterface
  class CandidateFeedbackExport
    def data_for_export(run_once_flag = false)
      application_forms.find_each.map do |application_form|
        {
          'Name' => application_form.full_name,
          'Recruitment cycle year' => application_form.recruitment_cycle_year,
          'Email_address' => application_form.candidate.email_address,
          'Phone number' => application_form.phone_number,
          'Submitted at' => application_form.submitted_at&.iso8601,
          'Satisfaction level' => application_form.feedback_satisfaction_level,
          'CSAT score' => csat_score(application_form.feedback_satisfaction_level),
          'Suggestions' => application_form.feedback_suggestions,
        }
        break if run_once_flag
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
