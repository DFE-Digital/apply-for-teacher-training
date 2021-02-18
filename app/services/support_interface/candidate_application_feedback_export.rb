module SupportInterface
  class CandidateApplicationFeedbackExport
    def data_for_export(run_once_flag = false)
      application_feedback.map do |feedback|
        {
          'Name' => feedback.application_form.full_name,
          'Recruitment cycle year' => feedback.application_form.recruitment_cycle_year,
          'Email_address' => feedback.application_form.candidate.email_address,
          'Phone number' => feedback.application_form.phone_number,
          'Submitted at' => feedback.created_at.iso8601,
          'Path' => feedback.path,
          'Page title' => feedback.page_title,
          'Feedback' => feedback.feedback,
          'Consent to be contacted' => feedback.consent_to_be_contacted,
        }
        break if run_once_flag
      end
    end

  private

    def application_feedback
      ApplicationFeedback.all.includes(%i[application_form candidate]).sort_by do |feedback|
        feedback.application_form.full_name
      end
    end
  end
end
