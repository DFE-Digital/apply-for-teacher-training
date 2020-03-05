module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    TimelineEntry = Struct.new(:actor, :action, :date)

    STATUSES_TO_INCLUDE = %w[
      awaiting_provider_decision
      rejected
      offer
      declined
      pending_conditions
      conditions_not_met
      recruited
      enrolled
    ].freeze

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def entries
      relevant_audits = @application_choice.audits.where("audited_changes->>'status' IS NOT NULL").order(created_at: :desc)

      relevant_audits.map(&:user)
      relevant_audits.reduce([]) do |chronology, audit|
        new_status = Array.wrap(audit.audited_changes['status']).second

        if new_status.present? && timeline_should_include?(new_status)
          chronology.push(TimelineEntry.new(actor_for(audit), action_for(new_status), audit.created_at))
        end

        chronology
      end
    end

  private

    def timeline_should_include?(status)
      STATUSES_TO_INCLUDE.include?(status)
    end

    def actor_for(audit)
      if audit.user_type == "Candidate"
        'candidate'
      else
        audit.user
      end
    end

    def action_for(new_status)
      {
        'awaiting_provider_decision' => 'Application submitted',
        'rejected' => 'Application rejected',
        'offer' => 'Offer made',
        'declined' => 'Offer declined',
        'pending_conditions' => 'Offer accepted',
        'conditions_not_met' => 'Conditions marked not met',
        'recruited' => 'Conditions marked met',
        'enrolled' => 'Candidate enrolled',
      }.fetch(new_status)
    end
  end
end
