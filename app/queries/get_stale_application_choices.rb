class GetStaleApplicationChoices
  def self.call
    scope = if RecruitmentCycle.current_year == 2024
              ApplicationChoice.awaiting_provider_decision.order(:application_form_id)
            else
              ApplicationChoice.decision_pending.order(:application_form_id)
            end

    application_choices_past_reject_by_default_at(scope)
  end

  def self.application_choices_past_reject_by_default_at(scope)
    scope.where('reject_by_default_at < ?', Time.zone.now)
  end
end
