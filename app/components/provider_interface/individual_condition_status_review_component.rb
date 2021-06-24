module ProviderInterface
  class IndividualConditionStatusReviewComponent < ViewComponent::Base
    attr_reader :form_object, :application_choice

    def initialize(form_object:, application_choice:)
      @form_object = form_object
      @application_choice = application_choice
    end

    def page_heading
      if form_object.all_conditions_met?
        'Check your changes and mark conditions as met'
      elsif form_object.any_condition_not_met?
        'Check your changes and mark conditions as not met'
      else
        'Check and update status of conditions'
      end
    end

    def confirm_button_text
      if form_object.all_conditions_met?
        'Mark conditions as met and tell candidate'
      elsif form_object.any_condition_not_met?
        'Mark conditions as not met'
      else
        'Update status'
      end
    end

    def confirm_button_class
      'govuk-button--warning' if form_object.any_condition_not_met?
    end
  end
end
