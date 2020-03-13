module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    Event = Struct.new(:title, :actor, :date)

  private

    def events
      audits = StateChangeAudits.new(application_choice: application_choice)
      audits.map do |audit|
        Event.new(
          title_for(audit),
          actor_for(audit),
          audit.created_at,
        )
      end
    end

    def title_for(_audit)
      'Application submitted'
    end

    def actor_for(_audit)
      'candidate'
    end
  end
end
