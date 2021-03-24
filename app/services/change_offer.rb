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
    change_an_offer = ChangeAnOffer.new(actor: actor,
                                        application_choice: application_choice,
                                        course_option: course_option,
                                        offer_conditions: conditions)
    unless change_an_offer.save
      if change_an_offer.errors[:base].include?('The new offer is identical to the current offer')
        raise IdenticalOfferError, 'The new offer is identical to the current offer'
      elsif change_an_offer.errors[:course_option].present?
        raise CourseValidationError, change_an_offer.errors[:course_option].join
      else
        raise 'Unable to complete save on change_an_offer'
      end
    end
  end

  class IdenticalOfferError < StandardError; end
  class CourseValidationError < StandardError; end
end
