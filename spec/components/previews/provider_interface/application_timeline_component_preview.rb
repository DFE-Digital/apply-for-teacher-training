module ProviderInterface
  class ApplicationTimelineComponentPreview < ViewComponent::Preview
    def awaiting_references
      application_choice = ApplicationChoice.where(status: 'awaiting_references').sample
      render_component_for application_choice: application_choice
    end

    def rejected
      application_choice = ApplicationChoice.where(status: 'rejected').sample
      render_component_for application_choice: application_choice
    end

    def accepted
      application_choice = ApplicationChoice.where(status: 'pending_conditions').sample
      render_component_for application_choice: application_choice
    end

    def enrolled
      application_choice = ApplicationChoice.where(status: 'enrolled').sample
      render_component_for application_choice: application_choice
    end

    def withdrawn
      application_choice = ApplicationChoice.where(status: 'withdrawn').sample
      render_component_for application_choice: application_choice
    end

  private

    def render_component_for(application_choice:)
      if application_choice
        render ApplicationTimelineComponent.new(application_choice: application_choice)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
