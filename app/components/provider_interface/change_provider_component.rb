module ProviderInterface
  class ChangeProviderComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :application_choice, :providers

    def initialize(form_object:, application_choice:, providers:)
      @form_object = form_object
      @application_choice = application_choice
      @providers = providers.order(:name)
    end

    def full_name
      application_choice.application_form.full_name
    end

    def page_title
      'Select training provider'
    end
  end
end
