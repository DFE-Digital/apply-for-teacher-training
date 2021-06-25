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
      user = event.user_full_name
      candidate = event.candidate_full_name

      return interview_event_description(user, candidate) if event.audit.auditable.is_a?(Interview)

      case event.application_status_at_event
      when 'awaiting_provider_decision'
        "Application received from #{candidate}"
      when 'withdrawn'
        "#{candidate} withdrew their application"
      when 'rejected'
        if application_choice.rejected_by_default
          "#{candidate}’s application was automatically rejected"
        else
          "#{user} rejected #{candidate}’s application"
        end
      when 'offer'
        "#{user} made an offer to #{candidate}"
      when 'offer_withdrawn'
        "#{user} withdrew #{candidate}’s offer"
      when 'declined'
        if application_choice.declined_by_default
          "#{candidate}’s offer was automatically declined"
        else
          "#{candidate} declined an offer"
        end
      when 'pending_conditions'
        "#{candidate} accepted an offer"
      when 'conditions_not_met'
        "#{user} marked #{candidate}’s offer conditions as not met"
      when 'recruited'
        "#{user} marked #{candidate}’s offer conditions as all met"
      when 'offer_deferred'
        "#{user} deferred #{candidate}’s offer"
      else
        if changes['reject_by_default_feedback_sent_at'].present?
          "#{user} sent feedback to #{candidate}"
        elsif changes['offer_changed_at'].present?
          "#{user} changed the offer made to #{candidate}"
        end
      end
    end

    def course_option
      current_status = event.application_status_at_event || application_choice.status

      changed_option_id = changes['current_course_option_id']&.second
      changed_option_id ||= changes['offered_course_option_id']&.second
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
        "Interviewing on #{interview.date_and_time.to_s(:govuk_date_and_time)}, #{interview.location}"
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
      else
        application_link
      end
    end

    def interview_event_description(user, candidate)
      return "#{user} set up an interview with #{candidate}" if event.audit.action == 'create'
      return "#{user} cancelled interview with #{candidate}" if event.audit.audited_changes.key?('cancelled_at')

      "#{user} updated interview with #{candidate}"
    end

  private

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
  end
end
