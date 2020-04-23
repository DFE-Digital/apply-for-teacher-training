module ProviderInterface
  class TrainingWithDisabilityComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      application_form.disclose_disability? && disability_disclosure.present?
    end

    def disability_disclosure
      @application_form.disability_disclosure
    end
  end
end
