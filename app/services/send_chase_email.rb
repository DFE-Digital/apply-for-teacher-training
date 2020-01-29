class SendChaseEmail
  def perform(reference:)
    RefereeMailer.reference_request_chaser_email(reference.application_form, reference)

    reference.application_form.application_choices.each do |application_choice|
      application_choice.update!(status: 'awaiting_references_and_chased')
    end
  end
end
