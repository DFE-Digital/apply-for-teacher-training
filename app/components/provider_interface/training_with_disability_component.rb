module ProviderInterface
  class TrainingWithDisabilityComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_form
    delegate :disclose_disability?, :disability_disclosure, to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      rows = [{ key: I18n.t('application_form.training_with_a_disability.disclose_disability.label'), value: disability_disclosure_support }]

      if disclose_information?
        rows << { key: I18n.t('application_form.training_with_a_disability.disability_disclosure.label'), value: disability_disclosure }
      end

      rows
    end

  private

    def disclose_information?
      disclose_disability? && disability_disclosure.present?
    end

    def disability_disclosure_support
      if disclose_information?
        I18n.t('application_form.training_with_a_disability.disclose_disability.yes')
      else
        I18n.t('application_form.training_with_a_disability.disclose_disability.no')
      end
    end
  end
end
