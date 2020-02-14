class SendCandidateRejectionEmail
  def self.call(application_choice:)
    candidate_application_choices = application_choice.application_form.application_choices

    if candidate_application_choices.all?(&:rejected?)
      CandidateMailer.send(:all_application_choices_rejected, application_choice).deliver_later

      audit_comment =
        "New rejection email sent to candidate #{application_choice.application_form.candidate.email_address} for " +
        "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}."
      application_choice.application_form.update!(audit_comment: audit_comment)
    end
  end
end
