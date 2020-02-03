class GetRefereesToChase
  def perform
    references = ApplicationReference.includes(:application_form).feedback_requested

    references_with_applications_submitted_in_the_last_5_days = references.select do |reference|
      reference.application_form.submitted_at < Time.zone.now - 5.days
    end

    references_with_applications_submitted_in_the_last_5_days.select do |reference|
      reference.chasers_sent.referee_mailer_reference_request_chaser_email.blank?
    end
  end
end
