class RecruitedWithPendingConditions < HasPendingSkeConditionsOnly
  def call
    application_choice.recruited? && pending_ske_conditions_only?
  end
end
