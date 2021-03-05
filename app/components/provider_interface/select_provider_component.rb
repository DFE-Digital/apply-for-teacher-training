module ProviderInterface
  class SelectProviderComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :form_object, :form_path, :providers, :page_title, :provider_id

    def initialize(form_object:, form_path:, providers:, page_title: 'Select provider')
      @form_object = form_object
      @form_path = form_path
      @providers = providers
      @page_title = page_title
    end
  end
end
