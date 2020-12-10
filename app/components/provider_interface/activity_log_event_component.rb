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

      case event.application_status_at_event
      when 'awaiting_provider_decision'
        "#{candidate} submitted an application"
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
      when 'recruited'
        "#{candidate} met all offer conditions"
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

      @course_option ||= if changes['offer_changed_at'].present? && changes['offered_course_option_id'].present?
                           from_event = CourseOption.find_by(id: changes['offered_course_option_id'].second)
                           from_event || application_choice.offered_option
                         elsif ORIGINAL_OPTION_STATUSES.include?(current_status)
                           application_choice.course_option
                         else
                           application_choice.offered_option
                         end
    end

    def link
      routes = Rails.application.routes.url_helpers

      case event.application_status_at_event
      when 'offer'
        {
          url: routes.provider_interface_application_choice_offer_path(application_choice),
          text: 'View offer',
        }
      when 'pending_conditions'
        {
          url: routes.provider_interface_application_choice_offer_path(application_choice),
          text: 'View offer',
        }
      else
        if changes['reject_by_default_feedback_sent_at'].present?
          {
            url: routes.provider_interface_application_choice_path(application_choice),
            text: 'View feedback',
          }
        elsif changes['offer_changed_at'].present? && application_choice.status == 'offer'
          {
            url: routes.provider_interface_application_choice_offer_path(application_choice),
            text: 'View offer',
          }
        else
          {
            url: routes.provider_interface_application_choice_path(application_choice),
            text: 'View application',
          }
        end
      end
    end
  end
end
