module ProviderInterface
  class ActivityLogEventComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def awaiting_provider_decision
      @activity_log_event = build_event_for_choice :awaiting_provider_decision
      render_component
    end

    def withdrawn
      @activity_log_event = build_event_for_choice :withdrawn
      render_component
    end

    def with_rejection
      @activity_log_event = build_event_for_choice :with_rejection
      render_component
    end

    def with_rejection_by_default
      @activity_log_event = build_event_for_choice :with_rejection_by_default
      render_component
    end

    def rejected_by_default_with_feedback
      @activity_log_event = build_event_for_choice :with_rejection_by_default_and_feedback
      render_component
    end

    def with_offer
      @activity_log_event = build_event_for_choice :with_offer
      render_component
    end

    def with_modified_offer
      @activity_log_event = build_event_for_choice :with_modified_offer
      render_component
    end

    def with_changed_offer
      @activity_log_event = build_event_for_choice :with_changed_offer
      render_component
    end

    def with_accepted_offer
      @activity_log_event = build_event_for_choice :with_accepted_offer
      render_component
    end

    def with_declined_offer
      @activity_log_event = build_event_for_choice :with_declined_offer
      render_component
    end

    def with_declined_by_default_offer
      @activity_log_event = build_event_for_choice :with_declined_by_default_offer
      render_component
    end

    def with_withdrawn_offer
      @activity_log_event = build_event_for_choice :with_withdrawn_offer
      render_component
    end

    def with_conditions_not_met
      @activity_log_event = build_event_for_choice :with_conditions_not_met
      render_component
    end

    def with_recruited
      @activity_log_event = build_event_for_choice :with_recruited
      render_component
    end

    def with_deferred_offer
      @activity_log_event = build_event_for_choice :with_deferred_offer
      render_component
    end

  private

    def build_event_for_choice(trait)
      audit = FactoryBot.create(:application_choice_audit, trait)
      ActivityLogEvent.new(audit:)
    end

    def render_component
      render ProviderInterface::ActivityLogEventComponent.new(
        activity_log_event: @activity_log_event,
      )
    end
  end
end
