class GetReferencesToChase
  def self.call
    if FeatureFlag.active?(:decoupled_references)
      ApplicationReference
        .feedback_requested
        .where(['requested_at < ?', chase_referee_time_limit])
        .where(application_form_id: ApplicationForm.where(submitted_at: nil).pluck(:id))
        .where.not(id: ChaserSent.reference_request.select(:chased_id))
    else
      ApplicationReference
        .feedback_requested
        .where(['requested_at < ?', chase_referee_time_limit])
        .where.not(id: ChaserSent.reference_request.select(:chased_id))
    end
  end

  def self.chase_referee_time_limit
    TimeLimitConfig.chase_referee_by.days.before(Time.zone.now)
  end
end
