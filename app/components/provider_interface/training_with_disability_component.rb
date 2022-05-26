module ProviderInterface
  class TrainingWithDisabilityComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form
    delegate :disclose_disability?, :disability_disclosure, to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      rows = [{ key: 'Do you want to ask for help to become a teacher?', value: disability_disclosure_support }]

      if disclose_information?
        rows << { key: 'Give any relevant information', value: disability_disclosure }
      end

      rows
    end

  private

    def disclose_information?
      disclose_disability? && disability_disclosure.present?
    end

    def disability_disclosure_support
      if disclose_information?
        'Yes, I want to share information about myself so my provider can take steps to support me'
      else
        'No'
      end
    end
  end
end
