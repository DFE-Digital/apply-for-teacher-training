module ProviderInterface
  class WorkHistoryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def application
      render_component_for application_form: application_form
    end

  private

    def application_form
      @application_form ||= ApplicationForm.joins(
        :application_work_experiences,
        :application_work_history_breaks,
      ).limit(25).sample
    end

    def render_component_for(application_form:)
      if application_form
        render WorkHistoryComponent.new(application_form: application_form)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
