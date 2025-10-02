class CandidateInterface::ApplicationVisibilityComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def render?
    FeatureFlag.active?(:candidate_preferences) && application_form.submitted_applications?
  end

  def pool_opt_in?
    application_form.published_preference&.opt_in?
  end

  def invisible?
    application_form&.awaiting_provider_decisions?
  end
end
