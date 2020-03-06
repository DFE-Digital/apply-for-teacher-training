module ProviderInterface
  class VolunteeringHistoryComponentPreview < ActionView::Component::Preview
    def with_work_history
      render_component_for application_form: ApplicationForm.last
    end

  private

    def render_component_for(application_form:)
      if !application_form.application_work_experiences.empty?
        render ProviderInterface::VolunteeringHistoryComponent.new(application_form: application_form)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
