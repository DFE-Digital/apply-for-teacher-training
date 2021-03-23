class MakeOffer
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
    check_existing_offer!

    make_an_offer = MakeAnOffer.new(actor: actor,
                                    application_choice: application_choice,
                                    course_option: course_option,
                                    offer_conditions: conditions)
    make_an_offer.save

    if make_an_offer.errors[:base].include?(MakeAnOffer::STATE_TRANSITION_ERROR)
      raise NoTransitionAllowedError, MakeAnOffer::STATE_TRANSITION_ERROR
    elsif make_an_offer.errors[:course_option].present?
      raise CourseValidationError, make_an_offer.errors[:course_option].join
    end
  end

  class CourseValidationError < StandardError; end
  class RatifyingProviderChangeError < StandardError; end
  class ConditionsValidationError < StandardError; end
  class AlreadyOfferedError < StandardError; end
  class NoTransitionAllowedError < StandardError; end
private

  def check_ratifying_provider_is_preserved!
    previous_ratifying_provider = application_choice.offered_course.accredited_provider || application_choice.offered_course.provider
    new_ratifiying_provider = course_option.course.accredited_provider || course_option.course.provider
    if previous_ratifying_provider != new_ratifiying_provider
      raise RatifyingProviderChangeError, 'The offer has a different ratifying provider to the application choice'
    end
  end

  def check_conditions!
    if conditions && conditions.count > MAX_CONDITIONS_COUNT
      raise ConditionsValidationError, 'Too many conditions specified (20 or fewer required)'
    elsif conditions.any? { |c| c.length > MAX_CONDITION_LENGTH }
      raise ConditionsValidationError, 'Condition exceeds length limit (255 characters or fewer required)'
    end
  end

  def check_existing_offer!
    if application_choice.offer?
      raise AlreadyOfferedError, 'An offer already exists, use ChangeOffer service to modify'
    end
  end
end
