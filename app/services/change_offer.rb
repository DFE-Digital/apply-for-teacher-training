class ChangeOffer
  attr_reader :actor, :application_choice, :course_option, :conditions

  MAX_CONDITIONS_COUNT = 20
  MAX_CONDITION_LENGTH = 255

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 conditions: [])
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @conditions = conditions
  end

  def save!
    check_ratifying_provider_is_preserved!
    check_conditions!

    change_an_offer = ChangeAnOffer.new(actor: actor,
                                        application_choice: application_choice,
                                        course_option: course_option,
                                        offer_conditions: conditions)

    unless change_an_offer.save
      if change_an_offer.errors[:base].include?('The new offer is identical to the current offer')
        raise IdenticalOfferError, 'The new offer is identical to the current offer'
      elsif change_an_offer.errors[:course_option].present?
        raise CourseValidationError, change_an_offer.errors[:course_option].join
      end
    end
  end

  class IdenticalOfferError < StandardError; end
  class CourseValidationError < StandardError; end
  class RatifyingProviderChangeError < StandardError; end
  class ConditionsValidationError < StandardError; end
private

  def check_ratifying_provider_is_preserved!
    previous_ratifying_provider = application_choice.offered_course.accredited_provider || application_choice.offered_course.provider
    new_ratifiying_provider = course_option.course.accredited_provider || course_option.course.provider
    if previous_ratifying_provider != new_ratifiying_provider
      raise RatifyingProviderChangeError, 'The new offer has a different ratifying provider to the current offer'
    end
  end

  def check_conditions!
    if conditions && conditions.count > MAX_CONDITIONS_COUNT
      raise ConditionsValidationError, 'Too many conditions specified (20 or fewer required)'
    elsif conditions.any? { |c| c.length > MAX_CONDITION_LENGTH }
      raise ConditionsValidationError, 'Condition exceeds length limit (255 characters or fewer required)'
    end
  end
end
