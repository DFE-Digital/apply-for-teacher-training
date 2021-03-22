class ChangeOffer
  attr_reader :actor, :application_choice, :course_option, :conditions

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
    if offer_changes_ratifying_provider?
      raise RatifyingProviderChange, 'The new offer has a different ratifying provider to the current offer'
    end

    change_an_offer = ChangeAnOffer.new(actor: actor,
                                        application_choice: application_choice,
                                        course_option: course_option,
                                        offer_conditions: conditions)

    unless change_an_offer.save
      if change_an_offer.errors[:base].include?('The new offer is identical to the current offer')
        raise IdenticalOffer, 'The new offer is identical to the current offer'
      elsif change_an_offer.errors[:course_option].present?
        raise CourseValidationError, change_an_offer.errors[:course_option].join
      end
    end
  end

  class IdenticalOffer < StandardError; end
  class CourseValidationError < StandardError; end
  class RatifyingProviderChange < StandardError; end
private

  def offer_changes_ratifying_provider?
    previous_ratifying_provider = application_choice.offered_course.accredited_provider || application_choice.offered_course.provider
    new_ratfiying_provider = course_option.course.accredited_provider || course_option.course.provider
    previous_ratifying_provider != new_ratfiying_provider
  end
end
