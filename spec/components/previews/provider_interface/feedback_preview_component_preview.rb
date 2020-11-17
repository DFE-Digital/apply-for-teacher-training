module ProviderInterface
  class FeedbackPreviewComponentPreview < ViewComponent::Preview
    def feedback_flow_for_direct_rejection
      find_application_choice rejected_by_default: false
      render_component
    end

    def feedback_flow_for_rejected_by_default
      find_application_choice rejected_by_default: true
      render_component
    end

  private

    def find_application_choice(rejected_by_default:)
      @application_choice = ApplicationChoice.order('RANDOM()').find_by(
        rejected_by_default: rejected_by_default,
      )
    end

    def render_component
      if @application_choice
        render ProviderInterface::FeedbackPreviewComponent.new(
          application_choice: @application_choice,
          rejection_reason: Faker::Lorem.paragraph_by_chars(number: 200),
        )
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
