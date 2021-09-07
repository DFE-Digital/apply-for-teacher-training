class OfferValidations
  include ActiveModel::Model

  MAX_CONDITIONS_COUNT = 20
  # This is required for the API integrations which send conditions together
  MAX_CONDITION_1_LENGTH = 2000
  MAX_CONDITION_LENGTH = 255

  attr_accessor :application_choice, :course_option, :conditions

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
    return unless application_choice.offer?

    if application_choice.current_course_option == course_option && application_choice.offer.conditions_text.sort == conditions.sort
      raise IdenticalOfferError
    end
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

    if !candidate_in_apply_2? && application_choice.application_form.apply_1? && any_accepted_offers?
      errors.add(:base, :other_offer_already_accepted)
    end

    if candidate_in_apply_2? && !application_choice.candidate.current_application_choice.eql?(application_choice)
      errors.add(:base, :only_latest_application_rejection_can_be_reverted_on_apply_2)
    end
  end

private

  def any_accepted_offers?
    ((application_choice.self_and_siblings - [application_choice]).map(&:status).map(&:to_sym) & ApplicationStateChange::ACCEPTED_STATES).any?
  end

  def candidate_in_apply_2?
    application_choice.candidate.in_apply_2?
  end
end
