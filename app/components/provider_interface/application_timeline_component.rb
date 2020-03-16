module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    Event = Struct.new(:title, :actor, :date)

    TITLES = {
      'withdrawn' => 'Application withdrawn',
      'awaiting_references' => 'Application submitted',
      'application_complete' => 'References received',
      'awaiting_provider_decision' => 'Sent to provider',
      'rejected' => 'Application rejected',
      'offer' => 'Offer made',
      'pending_conditions' => 'Offer accepted',
      'declined' => 'Offer declined',
      'recruited' => 'Recruited',
      'enrolled' => 'Enrolled',
      'conditions_not_met' => 'Conditions not met',
    }.freeze

  private

    def events
      changes = FindStatusChangeAudits.new(application_choice: application_choice).call
      changes.map do |change|
        Event.new(
          title_for(change),
          actor_for(change),
          change.changed_at,
        )
      end
    end

    def title_for(change)
      TITLES[change.status]
    end

    def actor_for(change)
      if change.user.is_a?(Candidate)
        'candidate'
      elsif change.user.is_a?(ProviderUser)
        # TODO: Work out how to display the provider name (it's ambiguous)
        change.user.full_name
      else
        'system'
      end
    end
  end
end
