class GetApplicationChoicesReadyToDeclineByDefault
  def self.call
    scope = ApplicationChoice.where(status: :offer)
    application_choices_past_decline_by_default_at(scope)
  end

  def self.application_choices_past_decline_by_default_at(scope)
    scope.where('decline_by_default_at < ?', Time.zone.now)
  end
end
