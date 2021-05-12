module ProviderInterface
  class ConditionsFormComponent < ViewComponent::Base
    include CheckboxOptionsHelper
    attr_reader :form_object, :application_choice, :form_method, :form_heading

    def initialize(form_object:, application_choice:, form_method:, form_heading:)
      @form_object = form_object
      @application_choice = application_choice
      @form_method = form_method
      @form_heading = form_heading
    end
  end
end
