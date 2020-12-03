module ProviderInterface
  class ActivityLogEventComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :event, :application_choice

    ORIGINAL_OPTION_STATUSES = %w[awaiting_provider_decision rejected].freeze

    def initialize(activity_log_event:)
      @event = activity_log_event
      @application_choice = activity_log_event.auditable
    end

    def changes
      event.audited_changes
    end

    def application_status_at_event
      changes.key?('status') && changes['status'].second
    end

    def event_description
      user = event.user.try(:full_name) || event.user.try(:display_name)
      candidate = application_choice.application_form.full_name

      case application_status_at_event
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
        end
      end
    end

    def course_option
      current_status = application_status_at_event || application_choice.status

      @course_option ||= if ORIGINAL_OPTION_STATUSES.include?(current_status)
                           application_choice.course_option
                         else
                           application_choice.offered_option
                         end
    end

    def link
      routes = Rails.application.routes.url_helpers

      case application_status_at_event
      when 'offer'
        {
          url: routes.provider_interface_application_choice_offer_path(event.auditable),
          text: 'View offer',
        }
      when 'pending_conditions'
        {
          url: routes.provider_interface_application_choice_offer_path(event.auditable),
          text: 'View offer',
        }
      else
        if changes['reject_by_default_feedback_sent_at'].present?
          {
            url: routes.provider_interface_application_choice_path(event.auditable),
            text: 'View feedback',
          }
        else
          {
            url: routes.provider_interface_application_choice_path(event.auditable),
            text: 'View application',
          }
        end
      end
    end
  end
end
