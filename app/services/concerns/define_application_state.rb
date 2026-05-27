module DefineApplicationState
  ApplicationState = Data.define(:id,
                                 :visible_to_provider,
                                 :interviewable,
                                 :offered,
                                 :post_offered,
                                 :offer_accepted,
                                 :unsuccessful,
                                 :carry_over,
                                 :successful,
                                 :pending_provider_decision,
                                 :reapply,
                                 :terminal,
                                 :in_progress,
                                 :active_previous,
                                 :chase_referee) do
    alias_method :visible_to_provider?, :visible_to_provider
    alias_method :interviewable?, :interviewable
    alias_method :offered?, :offered
    alias_method :post_offered?, :post_offered
    alias_method :offer_accepted?, :offer_accepted
    alias_method :unsuccessful?, :unsuccessful
    alias_method :carry_over?, :carry_over
    alias_method :successful?, :successful
    alias_method :pending_provider_decision?, :pending_provider_decision
    alias_method :reapply?, :reapply
    alias_method :terminal?, :terminal
    alias_method :in_progress?, :in_progress
    alias_method :active_previous?, :active_previous
    alias_method :chase_referee?, :chase_referee

    delegate :to_s, to: :id

    def self.all
      [
        ApplicationState.new(id: :unsubmitted, visible_to_provider: false, interviewable: false, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false,
                             successful: false, pending_provider_decision: false, reapply: false, terminal: false,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :cancelled, visible_to_provider: false, interviewable: false, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: true, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :awaiting_provider_decision, visible_to_provider: true, interviewable: true,
                             offered: false, post_offered: false, offer_accepted: false, unsuccessful: false,
                             carry_over: false, successful: false, pending_provider_decision: true, reapply: false,
                             terminal: false, in_progress: true, active_previous: true, chase_referee: false),
        ApplicationState.new(id: :inactive, visible_to_provider: true, interviewable: true, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: false,
                             successful: false, pending_provider_decision: false, reapply: false, terminal: true,
                             in_progress: false, active_previous: true, chase_referee: false),
        ApplicationState.new(id: :interviewing, visible_to_provider: true, interviewable: true, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false,
                             successful: false, pending_provider_decision: true, reapply: false, terminal: false,
                             in_progress: true, active_previous: true, chase_referee: false),
        ApplicationState.new(id: :offer, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: false, offer_accepted: false, unsuccessful: false, carry_over: false,
                             successful: true, pending_provider_decision: false, reapply: false, terminal: false,
                             in_progress: true, active_previous: true, chase_referee: false),
        ApplicationState.new(id: :pending_conditions, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false,
                             successful: true, pending_provider_decision: false, reapply: false, terminal: false,
                             in_progress: true, active_previous: true, chase_referee: true),
        ApplicationState.new(id: :recruited, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false,
                             successful: true, pending_provider_decision: false, reapply: false, terminal: true,
                             in_progress: true, active_previous: true, chase_referee: true),
        ApplicationState.new(id: :rejected, visible_to_provider: true, interviewable: false, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: true, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :application_not_sent, visible_to_provider: false, interviewable: false, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: false, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :offer_withdrawn, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: true, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :declined, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: true, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :withdrawn, visible_to_provider: true, interviewable: false, offered: false,
                             post_offered: false, offer_accepted: false, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: true, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :conditions_not_met, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: true, unsuccessful: true, carry_over: true,
                             successful: false, pending_provider_decision: false, reapply: false, terminal: true,
                             in_progress: false, active_previous: false, chase_referee: false),
        ApplicationState.new(id: :offer_deferred, visible_to_provider: true, interviewable: false, offered: true,
                             post_offered: true, offer_accepted: true, unsuccessful: false, carry_over: false,
                             successful: true, pending_provider_decision: false, reapply: false, terminal: false,
                             in_progress: true, active_previous: false, chase_referee: true),
      ]
    end

    def self.where(**args)
      all.select do |state|
        args.all? do |attr, values|
          Array.wrap(values).any? do |value|
            state.public_send(attr) == value
          end
        end
      end
    end

    def self.find(state_id)
      state_id = state_id.to_sym
      all.find { |state| state.id == state_id }
    end

    def self.state_ids(attribute_or_method = nil)
      if attribute_or_method.nil?
        all
      else
        try(attribute_or_method)
      end.map(&:id)
    rescue StandardError
      raise 'Application state does not exist'
    end

    def self.not_visible_to_provider
      where(visible_to_provider: false)
    end

    def self.visible_to_provider
      where(visible_to_provider: true)
    end

    def self.interviewable
      where(interviewable: true)
    end

    def self.offered
      where(offered: true)
    end

    def self.post_offered
      where(post_offered: true)
    end

    def self.offer_accepted
      where(offer_accepted: true)
    end

    def self.unsuccessful
      where(unsuccessful: true)
    end

    def self.carry_over
      where(carry_over: true)
    end

    def self.successful
      where(successful: true)
    end

    def self.pending_provider_decision
      where(pending_provider_decision: true)
    end

    def self.pending_provider_decision_or_inactive
      pending_provider_decision | where(id: :inactive)
    end

    def self.redactable
      pending_provider_decision_or_inactive
    end

    def self.reapply
      where(reapply: true)
    end

    def self.terminal
      where(terminal: true)
    end

    def self.in_progress
      where(in_progress: true)
    end

    def self.active_previous
      where(active_previous: true)
    end

    def self.chase_referee
      where(chase_referee: true)
    end

    def self.in_flight
      pending_provider_decision_or_inactive | offer_accepted
    end

    def self.withdrawable
      pending_provider_decision | successful
    end
  end
end
