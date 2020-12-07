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

    def with_rejection_by_default_and_feedback
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

    def with_recruited
      @activity_log_event = build_event_for_choice :with_recruited
      render_component
    end

    def with_deferred_offer
      @activity_log_event = build_event_for_choice :with_deferred_offer
      render_component
    end

  private

    def build_event_for_choice(*args)
      choice_args = [:application_choice].concat(args).concat [id: ApplicationChoice.all.sample.id]
      choice = FactoryBot.build(*choice_args)

      audit_args = [:application_choice_audit].concat(args).concat [application_choice: choice]
      FactoryBot.build(*audit_args)
    end

    def render_component
      render ProviderInterface::ActivityLogEventComponent.new(
        activity_log_event: @activity_log_event,
      )
    end
  end
end
