class CandidateInterface::ApplicationChoices::IndexContentComponent < ApplicationComponent
  def initialize(application_form:, with_title: true)
    @application_form = application_form
    @with_title = with_title
  end

  delegate :candidate, to: :application_form

  def call
    render content_component
  end

  def content_component
    if application_form.between_cycles?
      # Candidate may have inflight applications.
      # If not, they are given the opportunity to carry over
      CandidateInterface::AfterDeadlineContentComponent.new(application_form:)
    elsif active_previous_application.present?
      CandidateInterface::MultipleActiveApplicationsContentComponent.new(application_form:)
    else
      # This is BAU and the application is for the current cycle
      CandidateInterface::MidCycleContentComponent.new(application_form:, with_title:)
    end
  end

private

  attr_reader :application_form, :with_title

  def active_previous_application
    candidate.active_previous_application
  end
end
