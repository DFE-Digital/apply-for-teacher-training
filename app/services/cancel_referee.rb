class CancelReferee
  def call(reference:)
    reference.update!(feedback_status: :cancelled, cancelled_at: Time.zone.now)
    RefereeMailer.reference_cancelled_email(reference).deliver_later
  end
end
