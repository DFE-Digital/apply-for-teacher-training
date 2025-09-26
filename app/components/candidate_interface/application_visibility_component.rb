class CandidateInterface::ApplicationVisibilityComponent < ViewComponent::Base
  attr_reader :current_candidate, :application_form

  def initialize(current_candidate:, application_form:)
    @current_candidate = current_candidate
    @application_form = application_form
  end

  def render?
    FeatureFlag.active?(:candidate_preferences) && application_form.submitted_applications?
  end

  def pool_opt_in?
    current_candidate.published_preferences&.last&.opt_in?
  end

  def invisible?
    current_candidate.application_forms&.last&.awaiting_provider_decisions? || current_candidate.application_forms&.last&.offered?
  end
end
