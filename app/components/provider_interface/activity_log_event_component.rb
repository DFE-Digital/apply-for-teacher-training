module ProviderInterface
  class ActivityLogEventComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :event, :application_choice
    delegate :changes, to: :event

    ORIGINAL_OPTION_STATUSES = %w[awaiting_provider_decision rejected].freeze

    def initialize(activity_log_event:)
      @event = activity_log_event
      @application_choice = activity_log_event.application_choice
    end

    def event_description
      auditable_adapter(@event.audit.auditable_type).event_description
    end

    def course_option
      changed_option_id = changes['current_course_option_id']&.second || changes['offered_course_option_id']&.second
      option_at_time = CourseOption.find_by(id: changed_option_id)

      @course_option ||= if option_at_time.present?
                           option_at_time
                         elsif ORIGINAL_OPTION_STATUSES.include?(current_status)
                           application_choice.course_option
                         else
                           application_choice.current_course_option
                         end
    end

    def event_title
      if application_choice.present?
        "#{course_option.course.name_and_code} at #{course_option.site.name}"
      elsif event.audit.auditable.is_a?(Interview)
        interview = event.audit.auditable
        "Interviewing on #{interview.date_and_time.to_fs(:govuk_date_and_time)}, #{interview.location}"
      end
    end

    def event_content
      if application_choice.present?
        content = course_option.provider.name

        if course_option.course.accredited_provider.present?
          content += " – ratified by #{course_option.course.accredited_provider.name}"
        end
      end

      content
    end

    def link
      if %w[offer pending_conditions].include?(event.application_status_at_event) || (changes['offer_changed_at'].present? && application_choice.offer?)
        offer_link
      elsif changes['reject_by_default_feedback_sent_at'].present?
        feedback_link
      elsif event.audit.auditable.is_a?(Interview)
        interview_link(event.audit)
      elsif event.audit.auditable.is_a?(ApplicationForm)
        auditable_adapter(@event.audit.auditable_type).link
      else
        application_link
      end
    end

  private

    def auditable_adapter(auditable_type)
      case auditable_type
      when 'ApplicationChoice'
        ActivityLog::ApplicationChoice.new(event:)
      when 'ApplicationForm'
        ActivityLog::ApplicationForm.new(event:)
      when 'Interview'
        ActivityLog::Interview.new(event:)
      end
    end

    def routes
      @_routes ||= Rails.application.routes.url_helpers
    end

    def application_link
      {
        url: routes.provider_interface_application_choice_path(application_choice),
        text: 'View application',
      }
    end

    def offer_link
      {
        url: routes.provider_interface_application_choice_offer_path(application_choice),
        text: 'View offer',
      }
    end

    def feedback_link
      {
        url: routes.provider_interface_application_choice_feedback_path(application_choice),
        text: 'View feedback',
      }
    end

    def interview_link(audit)
      return if audit.auditable.cancelled?

      {
        url: routes.provider_interface_application_choice_interviews_path(audit.associated, anchor: "interview-#{audit.auditable.id}"),
        text: 'View interview',
      }
    end

    def current_status
      event.application_status_at_event || application_choice.status
    end
  end
end
