class MakeOffer
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
    MakeAnOffer.new(actor: actor,
                    application_choice: application_choice,
                    course_option: course_option,
                    offer_conditions: conditions)
  end
end
