class CandidateInterface::ApplicationChoices::IndexContentComponent < ViewComponent::Base
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    render content_component
  end

  def content_component
    if application_form.carry_over? && RecruitmentCycleTimetable.apply_open?
      CandidateInterface::CarryOverMidCycleComponent.new(application_form:)
    elsif application_form.after_apply_deadline?
      # Candidate may have inflight applications.
      # If not, they are given the opportunity to carry over
      CandidateInterface::AfterDeadlineContentComponent.new(application_form:)
    elsif application_form.before_apply_opens?
      # The candidate has carried over an application, but is not yet able to submit choices
      CandidateInterface::CarriedOverContentComponent.new(application_form:)
    else
      # This is BAU and the application is for the current cycle
      CandidateInterface::MidCycleContentComponent.new(application_form:)
    end
  end

private

  attr_reader :application_form
end
