class CandidateInterface::ApplicationVisibilityComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def render?
    application_form.submitted_applications? &&
      (
        pool_opt_out_or_no_preference? ||
        visible_to_providers? ||
        waiting_for_provider_decision? ||
        application_form.withdrawn_no_longer_training? ||
        offer?
      )
  end

  def pool_opt_in?
    application_form.published_preference&.opt_in?
  end

  def pool_opt_out_or_no_preference?
    application_form.published_preference&.opt_out? || application_form.published_preference.nil?
  end

  def waiting_for_provider_decision?
    application_form.awaiting_provider_decisions? # this includes 'interviewing' status
  end

  def offer?
    application_form.offered?
  end

  def visible_to_providers?
    application_form.candidate_pool_application.present? &&
      !waiting_for_provider_decision?
  end
end
