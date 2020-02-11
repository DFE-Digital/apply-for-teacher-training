class GetRefereesToChase
  def self.call
    ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', chase_referee_time_limit])
      .where.not(id: ChaserSent.reference_request.select(:chased_id))
  end

  def self.chase_referee_time_limit
    TimeLimitCalculator.new(rule: :chase_referee_by, effective_date: Time.zone.now).call[:time_in_past]
  end
end
