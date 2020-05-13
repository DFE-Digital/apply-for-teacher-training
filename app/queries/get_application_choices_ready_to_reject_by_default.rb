class GetApplicationChoicesReadyToRejectByDefault
  def self.call
    scope = ApplicationChoice.where(status: :awaiting_provider_decision)
    application_choices_past_reject_by_default_at(scope)
  end

  def self.application_choices_past_reject_by_default_at(scope)
    scope.where('reject_by_default_at < ?', Time.zone.now)
  end
end
