module ProviderInterface
  class TrainingWithDisabilityComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def disability_disclosure
      return application_form.disability_disclosure if application_form.disclose_disability? && application_form.disability_disclosure.present?

      'No information shared.'
    end
  end
end
