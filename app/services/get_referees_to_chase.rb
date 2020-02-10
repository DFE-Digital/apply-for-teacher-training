class GetRefereesToChase
  def self.call
    ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', Time.zone.now - 5.days])
      .where.not(id: ChaserSent.reference_request.select(:chased_id))
  end
end
