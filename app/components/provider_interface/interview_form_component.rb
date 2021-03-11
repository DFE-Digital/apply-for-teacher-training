module ProviderInterface
  class InterviewFormComponent < ViewComponent::Base
    attr_reader :application_choice, :form_model, :form_url, :form_heading

    def initialize(application_choice:, form_model:, form_url:, form_heading:)
      @application_choice = application_choice
      @form_model = form_model
      @form_url = form_url
      @form_heading = form_heading
    end

    def application_providers
      @_application_providers ||= application_choice.associated_providers
    end
  end
end
