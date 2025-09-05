module ProviderInterface
  class ApplicationChoiceHeaderComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice, :provider_can_respond, :provider_can_set_up_interviews, :course_associated_with_user_providers

    def initialize(application_choice:, provider_can_respond: false, provider_can_set_up_interviews: false, course_associated_with_user_providers: true)
      @application_choice = application_choice
      @provider_can_respond = provider_can_respond
      @provider_can_set_up_interviews = provider_can_set_up_interviews
      @course_associated_with_user_providers = course_associated_with_user_providers
    end

    def header_component
      header_component_class.new(
        application_choice:,
        provider_can_respond:,
        provider_can_set_up_interviews:,
      )
    end

    def header_component_class
      if set_up_interview? || respond_to_application? || waiting_for_interview?
        ApplicationHeaderComponents::RespondComponent
      elsif awaiting_decision_but_cannot_respond?
        ApplicationHeaderComponents::AwaitingDecisionCannotRespondComponent
      elsif offer_waiting_for_candidate_response?
        ApplicationHeaderComponents::OfferAwaitingCandidateResponseComponent
      elsif deferred_offer?
        ApplicationHeaderComponents::DeferredOfferComponent
      end
    end

    def sub_navigation_items
      sub_navigation_items = [application_navigation_item]

      sub_navigation_items.push(offer_navigation_item) if offer_present?
      if course_associated_with_user_providers.present?
        sub_navigation_items.push(references_navigation_item) unless application_choice.application_unsuccessful_without_inactive?
        sub_navigation_items.push(interviews_navigation_item) if interviews_present?
        sub_navigation_items.push(notes_navigation_item)
        sub_navigation_items.push(timeline_navigation_item)
        sub_navigation_items.push(feedback_navigation_item) if application_choice.display_provider_feedback?
        sub_navigation_items.push(emails_navigation_item) if HostingEnvironment.sandbox_mode?
      end

      sub_navigation_items
    end

    def show_inset_text?
      respond_to_application? ||
        deferred_offer? ||
        awaiting_decision_but_cannot_respond? ||
        set_up_interview? ||
        offer_waiting_for_candidate_response?
    end

    def respond_to_application?
      provider_can_respond && application_choice.decision_pending?
    end

    def deferred_offer?
      application_choice.status == 'offer_deferred'
    end

    def awaiting_decision_but_cannot_respond?
      !provider_can_respond && application_choice.decision_pending?
    end

    def set_up_interview?
      application_choice.decision_pending? && provider_can_set_up_interviews && !application_choice.interviewing?
    end

    def waiting_for_interview?
      provider_can_respond && application_choice.interviewing?
    end

    def offer_waiting_for_candidate_response?
      application_choice.offer?
    end

  private

    def application_navigation_item
      { name: 'Application', url: provider_interface_application_choice_path(application_choice) }
    end

    def interviews_navigation_item
      { name: 'Interviews', url: provider_interface_application_choice_interviews_path(application_choice) }
    end

    def offer_navigation_item
      { name: 'Offer', url: provider_interface_application_choice_offer_path(application_choice) }
    end

    def references_navigation_item
      { name: 'References', url: provider_interface_application_choice_references_path(application_choice) }
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
      application_choice.interviews.kept.any?
    end

    def offer_present?
      ApplicationStateChange::OFFERED_STATES.include?(application_choice.status.to_sym)
    end
  end
end
