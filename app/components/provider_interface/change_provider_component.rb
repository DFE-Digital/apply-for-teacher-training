module ProviderInterface
  class ChangeProviderComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :application_choice, :providers

    def initialize(form_object:, application_choice:, providers:)
      @form_object = form_object
      @application_choice = application_choice
      @providers = providers.order(:name)
    end

    def page_title
      if application_choice.offer? && form_object.entry == :provider
        'Change training provider'
      else
        'Select alternative training provider'
      end
    end

    def next_step_url
    end

    def next_step_method
      :get
    end
  end
end
