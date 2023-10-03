class CancelReferee
  def call(reference:)
    ApplicationForm.with_unsafe_application_choice_touches do
      reference.update!(feedback_status: :cancelled, cancelled_at: Time.zone.now)
    end

    RefereeMailer.reference_cancelled_email(reference).deliver_later
  end
end
