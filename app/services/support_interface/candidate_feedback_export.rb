module SupportInterface
  class CandidateFeedbackExport
    def data_for_export
      application_forms.find_each.map do |application_form|
        {
          'Name' => application_form.full_name,
          'Recruitment cycle year' => application_form.recruitment_cycle_year,
          'Email_address' => application_form.candidate.email_address,
          'Phone number' => application_form.phone_number,
          'Satisfaction level' => application_form.feedback_satisfaction_level,
          'Suggestions' => application_form.feedback_suggestions,
        }
      end
    end

  private

    def application_forms
      @application_forms ||= ApplicationForm.where.not(
        feedback_satisfaction_level: nil,
      ).includes(:candidate)
    end
  end
end
