class CandidateInterface::ApplicationChoices::IndexContentComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    render content_component
  end

  def content_component
    if application_form.carry_over? # must be after_apply_deadline?
      if RecruitmentCycleTimetable.currently_between_cycles?
        # The candidate can carry over an application
        return CandidateInterface::CarryOverBetweenCyclesComponent.new(application_form: application_form)
      end

      # The candidate can carry over an application
      # We're probably in the next cycle at this point
      return CandidateInterface::CarryOverMidCycleComponent.new(application_form: application_form)
    end

    if application_form.after_apply_deadline?
      # It is after the deadline, but candidate has inflight applications (eg, awaiting decision)
      return CandidateInterface::AfterDeadlineContentComponent.new(application_form: application_form)
    end

    if application_form.before_apply_opens?
      # The candidate has carried over an application, but is not yet able to submit choices
      return CandidateInterface::CarriedOverContentComponent.new(application_form: application_form)
    end

    # This is BAU, candidates can find courses and apply
    CandidateInterface::MidCycleContentComponent.new(application_form: application_form)
  end

private

  attr_reader :application_form
end
