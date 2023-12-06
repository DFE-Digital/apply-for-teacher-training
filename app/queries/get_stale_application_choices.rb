class GetStaleApplicationChoices
  def self.call
    ApplicationChoice
      .awaiting_provider_decision
      .where('reject_by_default_at < ?', Time.zone.now)
      .order(:application_form_id)
  end
end
