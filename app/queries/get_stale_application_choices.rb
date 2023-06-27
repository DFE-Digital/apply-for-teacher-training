class GetStaleApplicationChoices
  def self.call
    scope = ApplicationChoice.decision_pending.order(:application_form_id)
    application_choices_past_reject_by_default_at(scope)
  end

  def self.application_choices_past_reject_by_default_at(scope)
    scope.where('reject_by_default_at < ?', Time.zone.now)
  end
end
