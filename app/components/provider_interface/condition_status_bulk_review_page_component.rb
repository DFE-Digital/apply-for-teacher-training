module ProviderInterface
  class ConditionStatusBulkReviewPageComponent < ViewComponent::Base
    attr_reader :form_object, :application_choice

    def initialize(form_object:, application_choice:)
      @form_object = form_object
      @application_choice = application_choice
    end

    def application_detail_rows
      [
        { key: 'Candidate name', value: application_choice.application_form.full_name },
        { key: 'Course', value: application_choice.course.name_and_code },
        { key: 'Preferred location', value: application_choice.site.name },
        { key: 'Provider', value: application_choice.course.provider.name_and_code },
      ]
    end
  end
end
