module ApplicationStateable
  extend ActiveSupport::Concern

  delegate :visible_to_provider?, :visible_to_provider, :interviewable?, :interviewable, :offered?, :offered,
           :post_offered?, :post_offered, :offer_accepted?, :offer_accepted, :unsuccessful?, :unsuccessful,
           :carry_over?, :carry_over, :successful?, :successful, :pending_provider_decision?, :pending_provider_decision,
           :reapply?, :reapply, :terminal?, :terminal, :in_progress?, :in_progress, :active_previous?, :active_previous,
           :chase_referee?, :chase_referee, to: :state, prefix: 'state'

  def state
    return nil unless try(:status)

    ApplicationStateChange::ApplicationState.find(status.to_sym)
  end

  def state_pending_provider_decision_or_inactive?
    state&.id == :inactive || state&.pending_provider_decision?
  end
end
