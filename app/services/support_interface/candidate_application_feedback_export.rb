module SupportInterface
  class CandidateApplicationFeedbackExport
    def data_for_export
      application_feedback.map do |feedback|
        {
          full_name: feedback.application_form.full_name,
          recruitment_cycle_year: feedback.application_form.recruitment_cycle_year,
          email: feedback.application_form.candidate.email_address,
          phone_number: feedback.application_form.phone_number,
          submitted_at: feedback.created_at.iso8601,
          path: feedback.path,
          page_title: feedback.page_title,
          feedback: feedback.feedback,
          consent_to_be_contacted: feedback.consent_to_be_contacted,
        }
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
