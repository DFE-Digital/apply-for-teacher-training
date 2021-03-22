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
    change_an_offer.save

    if change_an_offer.errors[:base].include?(MakeAnOffer::STATE_TRANSITION_ERROR)
      ApplicationStateChange.new(application_choice).make_offer!
    end
  end
end
