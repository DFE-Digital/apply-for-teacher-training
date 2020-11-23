module ProviderInterface
  class ApplicationChoiceHeaderComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :provider_can_respond

    def initialize(application_choice:, provider_can_respond: false)
      @application_choice = application_choice
      @provider_can_respond = provider_can_respond
    end

    def deferred_offer_wizard_applicable
      application_choice.status == 'offer_deferred' && application_choice.recruitment_cycle == RecruitmentCycle.previous_year
    end

    def deferred_offer_equivalent_course_option_available
      application_choice.status == 'offer_deferred' &&
        application_choice.offered_option.in_next_cycle &&
        application_choice.offered_option.in_next_cycle.course.open_on_apply
    end

    def sub_navigation_items
      sub_navigation_items = [
        { name: 'Application', url: provider_interface_application_choice_path(application_choice) },
      ]

      if offer_present?
        sub_navigation_items.push(
          { name: 'Offer', url: provider_interface_application_choice_offer_path(application_choice) },
        )
      end

      sub_navigation_items.push(
        { name: 'Notes', url: provider_interface_application_choice_notes_path(application_choice) },
      )

      sub_navigation_items.push(
        { name: 'Timeline', url: provider_interface_application_choice_timeline_path(application_choice) },
      )

      if HostingEnvironment.sandbox_mode?
        sub_navigation_items.push(
          { name: 'Emails (Sandbox only)', url: provider_interface_application_choice_emails_path(application_choice) },
        )
      end

      sub_navigation_items
    end

    def rejection_reason_required
      application_choice.status == 'rejected' &&
        application_choice.rejected_by_default &&
        application_choice.rejection_reason.blank?
    end

    def offer_present?
      ApplicationStateChange::OFFERED_STATES.include?(application_choice.status.to_sym)
    end
  end
end
