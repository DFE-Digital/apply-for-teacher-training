module ProviderInterface
  class ApplicationTimelineComponent < ViewComponent::Base
    include ViewHelper
    include AuditHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
      audits = GetActivityLogEvents.call(application_choices: ApplicationChoice.where(id: application_choice.id))
      @activity_log_events = audits.map { |audit| ActivityLogEvent.new(audit:) }
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
      @activity_log_events
        .reject { |event| event.application_status_at_event == 'interviewing' }
        .select { |event| event.changes.key?(attr) && event.changes['status']&.at(1) != 'inactive' }
        .map { |event| yield(event) }
    end

    def timeline_events
      [status_change_events,
       note_events,
       feedback_events,
       change_offer_events,
       interview_preference_events,
       personal_information_events,
       disability_disclosure_events,
       equality_diversity_events,
       contact_information_events,
       change_course_events,
       interview_events].flatten.sort_by(&:date).reverse
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
        application_choice.notes.order(:created_at).map do |note|
          Event.new(
            'Note added',
            actor_for(note),
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
          provider_interface_application_choice_offer_path(application_choice),
        )
      end
    end

    def change_course_events
      map_activity_log_events_for('course_changed_at') do |event|
        Event.new(
          'Course updated',
          actor_for(event),
          event.created_at,
          'View application',
          provider_interface_application_choice_path(application_choice),
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

    def interview_preference_events
      interviews, @activity_log_events = @activity_log_events.partition { |e| e.audit.audited_changes['interview_preferences'] }
      interviews.map do |event|
        Event.new(
          'Interview preference updated',
          actor_for(event),
          event.created_at,
          'View Application',
          provider_interface_application_choice_path(application_choice, anchor: 'interview-preferences-section'),
        )
      end
    end

    def personal_information_events
      attributes = ApplicationForm::ColumnSectionMapping.by_section('personal_information')
      information, @activity_log_events = @activity_log_events.partition { |e| e.audit.audited_changes.keys.intersect?(attributes) }
      information.map do |event|
        Event.new(
          'Personal information updated',
          actor_for(event),
          event.created_at,
          'View Application',
          provider_interface_application_choice_path(application_choice, anchor: 'personal-information-section'),
        )
      end
    end

    def contact_information_events
      attributes = ApplicationForm::ColumnSectionMapping.by_section('contact_information')
      information, @activity_log_events = @activity_log_events.partition { |e| e.audit.audited_changes.keys.intersect?(attributes) }
      information.map do |event|
        Event.new(
          'Contact information updated',
          actor_for(event),
          event.created_at,
          'View Application',
          provider_interface_application_choice_path(application_choice, anchor: 'contact-information-section'),
        )
      end
    end

    def disability_disclosure_events
      disability_disclosure, @activity_log_events = @activity_log_events.partition do |e|
        e.audit.audited_changes.key?('disability_disclosure')
      end
      disability_disclosure.map do |event|
        Event.new(
          'Disability disclosure updated',
          actor_for(event),
          event.created_at,
          'View Application',
          provider_interface_application_choice_path(application_choice, anchor: 'disability-disclosure-section'),
        )
      end
    end

    def equality_diversity_events
      equality_diversity, @activity_log_events = @activity_log_events.partition do |e|
        e.audit.audited_changes.key?('disability_disclosure')
      end
      equality_diversity.map do |event|
        Event.new(
          'Equality and Diversity updated',
          actor_for(event),
          event.created_at,
          'View Application',
          provider_interface_application_choice_path(application_choice, anchor: 'equality-diversity-section'),
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
        change.user.full_name
      elsif change.user.is_a?(VendorApiUser)
        "#{change.user.full_name} (Vendor API)"
      elsif note_by_support?(change) || change_by_support?(change.audit)
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
      ['View offer', provider_interface_application_choice_offer_path(application_choice)]
    end

    def interview_link_params(interview)
      return [nil, nil] if interview.discarded?

      ['View interview', provider_interface_application_choice_interviews_path(application_choice, anchor: "interview-#{interview.id}")]
    end

    def note_by_support?(change)
      change.is_a?(Note) && change.user.is_a?(SupportUser)
    end
  end
end
