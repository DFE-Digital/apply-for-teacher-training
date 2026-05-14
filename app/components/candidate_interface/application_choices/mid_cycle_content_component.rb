class CandidateInterface::ApplicationChoices::MidCycleContentComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  delegate :can_add_more_choices?, :unsuccessful_limit_reached?, to: :application_form

  def content_component
    if can_add_more_choices?
      CandidateInterface::ApplicationChoices::MidCycleAddMoreContentComponent.new(application_form:)
    elsif unsuccessful_limit_reached?
      CandidateInterface::ApplicationChoices::MidCycleUnsuccessfulContentComponent.new(application_form:)
    else
      CandidateInterface::ApplicationChoices::MidCycleCreationLimitContentComponent.new(application_form:)
    end
  end
end
