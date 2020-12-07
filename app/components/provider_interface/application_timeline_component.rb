module ProviderInterface
  class ApplicationTimelineComponent < ViewComponent::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
      audits = GetActivityLogEvents.call(application_choices: [application_choice])
      @activity_log_events = audits.map { |audit| ActivityLogEvent.new(audit: audit) }
    end

    Event = Struct.new(:title, :actor, :date, :link_name, :link_path)

    TITLES = {
      'awaiting_provider_decision' => 'Application submitted',
      'withdrawn' => 'Application withdrawn',
      'rejected' => 'Application rejected',
      'offer_withdrawn' => 'Offer withdrawn',
      'offer' => 'Offer made',
      'pending_conditions' => 'Offer accepted',
      'declined' => 'Offer declined',
      'recruited' => 'Recruited',
      'conditions_not_met' => 'Conditions marked not met',
      'offer_deferred' => 'Offer deferred',
    }.freeze

  private

    def with_activity_log_events_for(attr)
      filtered = @activity_log_events.select { |event| event.changes.key?(attr) }
      filtered.map { |event| yield event }
    end

    def timeline_events
      (status_change_events + note_events + feedback_events).sort_by(&:date).reverse
    end

    def status_change_events
      with_activity_log_events_for('status') do |event|
        Event.new(
          title_for(event.application_status_at_event),
          actor_for(event),
          event.created_at,
          *link_params_for_status(event.application_status_at_event),
        )
      end
    end

    def note_events
      if application_choice.notes.present?
        application_choice.notes.order('created_at').map do |note|
          Event.new(
            'Note added',
            provider_name(note.provider_user),
            note.created_at,
            'View note',
            provider_interface_application_choice_note_path(application_choice, note),
          )
        end
      else
        []
      end
    end

    def feedback_events
      with_activity_log_events_for('reject_by_default_feedback_sent_at') do |event|
        Event.new(
          'Feedback sent',
          actor_for(event),
          event.created_at,
          'View feedback',
          provider_interface_application_choice_path(application_choice),
        )
      end
    end

    def title_for(status)
      TITLES[status]
    end

    def actor_for(change)
      if change.user.is_a?(Candidate)
        'Candidate'
      elsif change.user.is_a?(ProviderUser)
        provider_name(change.user)
      else
        'System'
      end
    end

    def link_params_for_status(status)
      title_for(status).match(/^Application/) ? application_link_params : offer_link_params
    end

    def application_link_params
      ['View application', provider_interface_application_choice_path(application_choice)]
    end

    def offer_link_params
      ['View offer', provider_interface_application_choice_offer_path(application_choice)]
    end

    def provider_name(provider_user)
      # TODO: Work out how to display the provider name (it's ambiguous)
      provider_user.full_name
    end
  end
end
