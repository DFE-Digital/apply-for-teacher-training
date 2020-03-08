module ProviderInterface
  class WorkHistoryComponentPreview < ActionView::Component::Preview
    def last_application
      render_component_for application_form: ApplicationForm.last
    end

  private

    def render_component_for(application_form:)
      if !application_form.application_work_experiences.empty?
        render ProviderInterface::WorkHistoryComponent.new(application_form: application_form)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
