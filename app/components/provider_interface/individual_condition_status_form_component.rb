module ProviderInterface
  class IndividualConditionStatusFormComponent < ApplicationComponent
    attr_reader :form_object, :application_choice

    def initialize(form_object:, application_choice:)
      @form_object = form_object
      @application_choice = application_choice
    end
  end
end
