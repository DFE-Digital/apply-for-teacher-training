class CanRecruitWithPendingConditions
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    feature_flag_enabled? &&
      application_has_offer? &&
      offer_has_pending_ske_conditions? &&
      offer_has_no_unmet_non_ske_conditions? &&
      provider_is_scitt? &&
      course_is_within_time_limit?
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

  def provider_is_scitt?
    application_choice.provider&.provider_type&.to_s == SupportInterface::ProvidersFilter::SCITT
  end

  def course_is_within_time_limit?
    course_start_date.present? && course_start_date < 3.months.from_now
  end

  def course_start_date
    application_choice.course&.start_date
  end
end
