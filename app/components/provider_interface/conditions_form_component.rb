module ProviderInterface
  class ConditionsFormComponent < ViewComponent::Base
    include CheckboxOptionsHelper
    attr_reader :form_object, :application_choice, :method, :form_heading

    def initialize(form_object:, application_choice:, method:, form_heading:)
      @form_object = form_object
      @application_choice = application_choice
      @method = method
      @form_heading = form_heading
    end
  end
end
