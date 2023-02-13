module ProviderInterface
  class SkeReasonComponent < ViewComponent::Base
    attr_reader :application_choice, :offer_wizard, :form, :radio_options, :key

    def initialize(application_choice:, offer_wizard:, form:, radio_options: {}, key: :reason)
      @key = key
      @offer_wizard = offer_wizard
      @application_choice = application_choice
      @form = form
      @radio_options = radio_options
    end

    def subject
      @application_choice.current_course.subjects.first&.name
    end

    def options
      [
        OpenStruct.new(name: first_option_label),
        OpenStruct.new(name: second_option_label),
      ]
    end

    def first_option_label
      @offer_wizard.different_degree_option(@application_choice, subject)
    end

    def second_option_label
      @offer_wizard.outdated_degree(@application_choice, subject)
    end
  end
end
