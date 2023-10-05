class CanRecruitWithPendingConditions
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    feature_flag_enabled? &&
      application_has_offer? &&
      offer_has_pending_ske_conditions? &&
      offer_has_no_unmet_non_ske_conditions?
  end

private

  def feature_flag_enabled?
    FeatureFlag.active?(:recruit_with_pending_conditions)
  end

  def application_has_offer?
    application_choice.offer.present?
  end

  def offer_has_pending_ske_conditions?
    application_choice.offer.conditions.any? do |condition|
      condition.is_a?(SkeCondition) && condition.pending?
    end
  end

  def offer_has_no_unmet_non_ske_conditions?
    application_choice.offer.conditions.none? do |condition|
      !condition.is_a?(SkeCondition) && !condition.met?
    end
  end
end
