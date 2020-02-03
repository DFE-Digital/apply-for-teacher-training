class SendChaseEmail
  def perform(reference:)
    RefereeMailer.reference_request_chaser_email(reference.application_form, reference)
    ChaserSent.create(chased: reference, chaser_type: :referee_mailer_reference_request_chaser_email)
  end
end
