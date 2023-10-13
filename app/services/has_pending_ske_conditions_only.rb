class HasPendingSkeConditionsOnly
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def pending_ske_conditions_only?
    feature_flag_enabled? &&
      application_has_offer? &&
      offer_has_pending_ske_conditions? &&
      all_non_ske_conditions_met?
  end

private

  def feature_flag_enabled?
    FeatureFlag.active?(:recruit_with_pending_conditions)
  end

  def application_has_offer?
    application_choice.offer.present?
  end

  def offer_has_pending_ske_conditions?
    application_choice.offer.ske_conditions.any?(&:pending?)
  end

  def all_non_ske_conditions_met?
    non_ske_conditions = application_choice.offer.conditions - application_choice.offer.ske_conditions
    non_ske_conditions.all?(&:met?)
  end
end
