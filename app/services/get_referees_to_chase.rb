class GetRefereesToChase
  def self.call
    ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', 5.business_days.ago])
      .where.not(id: ChaserSent.reference_request.select(:chased_id))
  end
end
