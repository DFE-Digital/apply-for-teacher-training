module ProviderInterface
  class ActivityLogEventComponentPreview < ViewComponent::Preview
    include PreviewProviderHelper

    layout 'previews/provider'

    def awaiting_provider_decision
      application_choice(state: :awaiting_provider_decision)
      @activity_log_event = build_event_for_choice :awaiting_provider_decision
      render_component
    end

    def withdrawn
      application_choice(state: :withdrawn)
      @activity_log_event = build_event_for_choice :withdrawn
      render_component
    end

    def with_rejection
      application_choice(state: :rejected)
      @activity_log_event = build_event_for_choice :with_rejection
      render_component
    end

    def with_rejection_by_default
      application_choice(state: :rejected_by_default)
      @activity_log_event = build_event_for_choice :with_rejection_by_default
      render_component
    end

    def rejected_by_default_with_feedback
      application_choice(state: :rejected_by_default_with_feedback)
      @activity_log_event = build_event_for_choice :with_rejection_by_default_and_feedback
      render_component
    end

    def with_offer
      application_choice(state: :offer)
      @activity_log_event = build_event_for_choice :with_offer
      render_component
    end

    def with_modified_offer
      another_course_option
      application_choice(state: :course_changed_before_offer)
      @activity_log_event = build_event_for_choice :with_modified_offer
      render_component
    end

    def with_changed_offer
      another_course_option
      application_choice(state: :course_changed_after_offer)
      @activity_log_event = build_event_for_choice :with_changed_offer
      render_component
    end

    def with_accepted_offer
      application_choice(state: :accepted)
      @activity_log_event = build_event_for_choice :with_accepted_offer
      render_component
    end

    def with_declined_offer
      application_choice(state: :declined)
      @activity_log_event = build_event_for_choice :with_declined_offer
      render_component
    end

    def with_declined_by_default_offer
      application_choice(state: :declined_by_default)
      @activity_log_event = build_event_for_choice :with_declined_by_default_offer
      render_component
    end

    def with_withdrawn_offer
      application_choice(state: :offer_withdrawn)
      @activity_log_event = build_event_for_choice :with_withdrawn_offer
      render_component
    end

    def with_conditions_not_met
      application_choice(state: :conditions_not_met)
      @activity_log_event = build_event_for_choice :with_conditions_not_met
      render_component
    end

    def with_recruited
      application_choice(state: :recruited)
      @activity_log_event = build_event_for_choice :with_recruited
      render_component
    end

    def with_deferred_offer
      application_choice(state: :offer_deferred)
      @activity_log_event = build_event_for_choice :with_deferred_offer
      render_component
    end

  private

    def provider
      @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
    end

    def course
      @course ||= FactoryBot.create(:course, provider:)
    end

    def course_option
      @course_option ||= FactoryBot.create(:course_option, course: course)
    end

    def another_course
      @another_course ||= FactoryBot.create(:course, provider:)
    end

    def another_course_option
      @another_course_option ||= FactoryBot.create(:course_option, course: another_course)
    end

    def application_choice(state: :awaiting_provider_decision)
      @application_choice = FactoryBot.create(:application_choice, state, course_option:)
    end

    def build_event_for_choice(trait)
      audit = FactoryBot.create(:application_choice_audit, trait, application_choice: @application_choice)
      ActivityLogEvent.new(audit:)
    end

    def render_component
      render ProviderInterface::ActivityLogEventComponent.new(
        activity_log_event: @activity_log_event,
      )
    end
  end
end
