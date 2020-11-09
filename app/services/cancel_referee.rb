class CancelReferee
  def call(reference:)
    reference.update!(feedback_status: 'cancelled')
    RefereeMailer.reference_cancelled_email(reference).deliver_later
  end
end
