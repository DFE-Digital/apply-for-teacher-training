class OfferValidations
  include ActiveModel::Model

  MAX_CONDITIONS_COUNT = 20
  # This is required for the API integrations which send conditions together
  MAX_CONDITION_1_LENGTH = 2000
  MAX_CONDITION_LENGTH = 255

  attr_accessor :application_choice, :course_option, :conditions, :structured_conditions

  validates :course_option, presence: true
  validate :conditions_count, if: :conditions
  validate :conditions_length, if: :conditions
  validate :identical_to_existing_offer?, if: %i[application_choice course_option]
  validate :ratifying_provider_changed?, if: %i[application_choice course_option]
  validate :restrict_reverting_rejection, if: :application_choice

  def conditions_count
    return if conditions.count <= MAX_CONDITIONS_COUNT

    errors.add(:conditions, :too_many, count: MAX_CONDITIONS_COUNT)
  end

  def conditions_length
    conditions.each_with_index do |condition, index|
      if index.zero?
        errors.add(:conditions, :too_long, index: index + 1, limit: MAX_CONDITION_1_LENGTH) if condition.length > MAX_CONDITION_1_LENGTH
      elsif condition.length > MAX_CONDITION_LENGTH
        errors.add(:conditions, :too_long, index: index + 1, limit: MAX_CONDITION_LENGTH)
      end
    end
  end

  def identical_to_existing_offer?
    return false unless application_choice.offer?

    if application_choice.current_course_option == course_option &&
       application_choice.offer.all_conditions_text.sort == conditions.sort &&
       existing_ske_condition_details == new_ske_condition_details &&
       existing_reference_condition == new_reference_condition
      raise IdenticalOfferError
    end
  end

  def existing_reference_condition
    condition = application_choice.offer&.reference_condition

    return if condition.blank?

    condition.details.symbolize_keys.slice(:required, :description)
  end

  def new_reference_condition
    return if reference_condition.blank?

    reference_condition.details.symbolize_keys.slice(:required, :description)
  end

  def existing_ske_condition_details
    application_choice.offer.ske_conditions.map { |condition| condition.details.symbolize_keys.slice(:length, :reason, :subject) }.sort { |hash1, hash2| hash1[:name] <=> hash2[:name] }
  end

  def new_ske_condition_details
    ske_conditions.map { |condition| condition.details.symbolize_keys.slice(:length, :reason, :subject) }.sort_by { |hash| hash[:name] }
  end

  def ratifying_provider_changed?
    if application_choice.current_course.ratifying_provider != course_option.course.ratifying_provider
      errors.add(:base, :different_ratifying_provider)
    end
  end

  def restrict_reverting_rejection
    if application_choice.rejected_by_default
      errors.add(:base, :application_rejected_by_default)
    end

    if can_not_receive_other_offers?
      errors.add(:base, :other_offer_already_accepted)
    end

    if application_choice.candidate.current_application_choices.exclude?(application_choice)
      errors.add(:base, :only_latest_application_rejection_can_be_reverted_on_apply_2)
    end
  end

private

  def ske_conditions
    Array(structured_conditions).select do |structured_condition|
      structured_condition.is_a?(SkeCondition)
    end
  end

  def reference_condition
    Array(structured_conditions).find do |structured_condition|
      structured_condition.is_a?(ReferenceCondition)
    end
  end

  def can_not_receive_other_offers?
    (application_choice.self_and_siblings - [application_choice])
      .map(&:status).map(&:to_sym)
      .intersect?(ApplicationStateChange::ACCEPTED_STATES - [:conditions_not_met])
  end


end
