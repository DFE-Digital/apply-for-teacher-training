module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    Event = Struct.new(:title, :actor, :date)

    TITLES = {
      'awaiting_references' => 'Application submitted',
      'offer' => 'Offer made',
      'accepted' => 'Offer accepted',
      'declined' => 'Offer declined',
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
        'provider'
      else
        'system'
      end
    end
  end
end
