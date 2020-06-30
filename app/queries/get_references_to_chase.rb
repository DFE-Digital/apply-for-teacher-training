class GetReferencesToChase
  def self.call
    ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', chase_referee_time_limit])
      .where.not(id: ChaserSent.reference_request.select(:chased_id))
  end

  def self.chase_referee_time_limit
    TimeLimitConfig.chase_referee_by.days.before(Time.zone.now)
  end
end
