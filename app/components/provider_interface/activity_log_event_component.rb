module ProviderInterface
  class ActivityLogEventComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :event, :application_choice, :course_option

    def initialize(activity_log_event:)
      @event = activity_log_event
      @application_choice = event.auditable
      @course_option = @application_choice.offered_option
    end

    def event_description
      user = event.user.try(:full_name) || event.user.try(:display_name)
      candidate = application_choice.application_form.full_name
      changes = event.audited_changes

      case changes.key?('status') && changes['status'].second
      when 'awaiting_provider_decision'
        "#{candidate} submitted an application"
      when 'withdrawn'
        "#{candidate} withdrew their application"
      when 'rejected'
        if application_choice.rejected_by_default
          "#{candidate}’s application was rejected automatically"
        else
          "#{user} rejected #{candidate}’s application"
        end
      when 'offer'
        "#{user} made an offer to #{candidate}"
      when 'offer_withdrawn'
        "#{user} withdrew #{candidate}’s offer"
      when 'declined'
        if application_choice.declined_by_default
          "#{candidate}’s offer was declined automatically"
        else
          "#{candidate} declined an offer"
        end
      when 'pending_conditions'
        "#{candidate} accepted an offer"
      when 'recruited'
        "#{user} recruited #{candidate}"
      when 'offer_deferred'
        "#{user} deferred #{candidate}’s offer"
      else
        if changes['reject_by_default_feedback_sent_at'].present?
          "#{user} sent feedback to #{candidate}"
        end
      end
    end

    def link_destination
      Rails.application.routes.url_helpers.provider_interface_application_choice_path(
        application_choice.id,
      )
    end
  end
end
