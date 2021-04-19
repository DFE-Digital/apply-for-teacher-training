module ProviderInterface
  class ApplicationChoiceHeaderComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :provider_can_respond

    def initialize(application_choice:, provider_can_respond: false)
      @application_choice = application_choice
      @provider_can_respond = provider_can_respond
    end

    def sub_navigation_items
      sub_navigation_items = [application_navigation_item]

      sub_navigation_items.push(interviews_navigation_item) if interviews_present?
      sub_navigation_items.push(offer_navigation_item) if offer_present?
      sub_navigation_items.push(notes_navigation_item)
      sub_navigation_items.push(timeline_navigation_item)
      sub_navigation_items.push(feedback_navigation_item) if application_choice.display_provider_feedback?
      sub_navigation_items.push(emails_navigation_item) if HostingEnvironment.sandbox_mode?

      sub_navigation_items
    end

    def show_inset_text?
      respond_to_application? ||
        deferred_offer_wizard_applicable? ||
        rejection_reason_required? ||
        awaiting_decision_but_cannot_respond? ||
        waiting_for_interview? ||
        offer_will_be_declined_by_default?
    end

    def respond_to_application?
      provider_can_respond && application_choice.awaiting_provider_decision?
    end

    def deferred_offer_wizard_applicable?
      provider_can_respond &&
        application_choice.status == 'offer_deferred' &&
        application_choice.recruitment_cycle == RecruitmentCycle.previous_year
    end

    def deferred_offer_equivalent_course_option_available?
      application_choice.status == 'offer_deferred' &&
        application_choice.offered_option.in_next_cycle &&
        application_choice.offered_option.in_next_cycle.course.open_on_apply
    end

    def rejection_reason_required?
      provider_can_respond &&
        application_choice.status == 'rejected' &&
        application_choice.rejected_by_default &&
        application_choice.no_feedback?
    end

    def awaiting_decision_but_cannot_respond?
      !provider_can_respond && application_choice.decision_pending?
    end

    def waiting_for_interview?
      provider_can_respond && application_choice.interviewing?
    end

    def offer_will_be_declined_by_default?
      application_choice.offer? && application_choice.decline_by_default_at.present?
    end

    def decline_by_default_text
      return unless offer_will_be_declined_by_default?

      if time_is_today_or_tomorrow?(application_choice.decline_by_default_at)
        "at the end of #{date_and_time_today_or_tomorrow(application_choice.decline_by_default_at)}"
      else
        days_remaining = days_until(application_choice.decline_by_default_at.to_date)
        "in #{days_remaining} (#{application_choice.decline_by_default_at.to_s(:govuk_date_and_time)})"
      end
    end

  private

    def application_navigation_item
      { name: 'Application', url: provider_interface_application_choice_path(application_choice) }
    end

    def interviews_navigation_item
      { name: 'Interviews', url: provider_interface_application_choice_interviews_path(application_choice) }
    end

    def offer_navigation_item
      path = if FeatureFlag.active?(:updated_offer_flow)
               provider_interface_application_choice_offers_path(application_choice)
             else
               provider_interface_application_choice_offer_path(application_choice)
             end
      { name: 'Offer', url: path }
    end

    def notes_navigation_item
      { name: 'Notes', url: provider_interface_application_choice_notes_path(application_choice) }
    end

    def timeline_navigation_item
      { name: 'Timeline', url: provider_interface_application_choice_timeline_path(application_choice) }
    end

    def feedback_navigation_item
      { name: 'Feedback', url: provider_interface_application_choice_feedback_path(application_choice) }
    end

    def emails_navigation_item
      { name: 'Emails (Sandbox only)', url: provider_interface_application_choice_emails_path(application_choice) }
    end

    def interviews_present?
      return false unless FeatureFlag.active?(:interviews)

      application_choice.interviews.kept.any?
    end

    def offer_present?
      ApplicationStateChange::OFFERED_STATES.include?(application_choice.status.to_sym)
    end
  end
end
