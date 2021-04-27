module ProviderInterface
  class ApplicationTimelineComponent < ViewComponent::Base
    include ViewHelper
    include AuditHelper
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
      audits = GetActivityLogEvents.call(application_choices: ApplicationChoice.where(id: application_choice.id))
      @activity_log_events = audits.map { |audit| ActivityLogEvent.new(audit: audit) }
    end

    Event = Struct.new(:title, :actor, :date, :link_name, :link_path)

    TITLES = {
      'awaiting_provider_decision' => 'Application received',
      'interviewing' => 'Interviewing',
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

    def map_activity_log_events_for(attr)
      filtered = @activity_log_events.select { |event| event.application_status_at_event != 'interviewing' && event.changes.key?(attr) }
      filtered.map { |event| yield event }
    end

    def timeline_events
      (status_change_events + note_events + feedback_events + change_offer_events + interview_events).sort_by(&:date).reverse
    end

    def status_change_events
      map_activity_log_events_for('status') do |event|
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
      map_activity_log_events_for('reject_by_default_feedback_sent_at') do |event|
        Event.new(
          'Feedback sent',
          actor_for(event),
          event.created_at,
          'View feedback',
          provider_interface_application_choice_feedback_path(application_choice),
        )
      end
    end

    def change_offer_events
      map_activity_log_events_for('offer_changed_at') do |event|
        Event.new(
          'Offer changed',
          actor_for(event),
          event.created_at,
          'View offer',
          provider_interface_application_choice_offers_path(application_choice),
        )
      end
    end

    def interview_events
      @activity_log_events.select { |e| e.audit.auditable.is_a?(Interview) }.map do |event|
        Event.new(
          interview_title_for(event.audit),
          actor_for(event),
          event.created_at,
          *interview_link_params(event.audit.auditable),
        )
      end
    end

    def title_for(status)
      TITLES[status]
    end

    def interview_title_for(audit)
      if audit.action == 'create'
        'Interview set up'
      elsif audit.action == 'update' && audit.audited_changes.key?('cancelled_at')
        'Interview cancelled'
      else
        'Interview updated'
      end
    end

    def actor_for(change)
      if change.user.is_a?(Candidate)
        'Candidate'
      elsif change.user.is_a?(ProviderUser)
        provider_name(change.user)
      elsif change_by_support?(change.audit)
        'Apply support'
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
      ['View offer', provider_interface_application_choice_offers_path(application_choice)]
    end

    def interview_link_params(interview)
      return [nil, nil] if interview.discarded?

      ['View interview', provider_interface_application_choice_interviews_path(application_choice, anchor: "interview-#{interview.id}")]
    end

    def provider_name(provider_user)
      provider_user.full_name
    end
  end
end
