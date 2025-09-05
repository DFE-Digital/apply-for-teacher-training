module ProviderInterface
  class SkeLengthComponent < ApplicationComponent
    attr_reader :form, :offer_wizard

    SkeLength = Struct.new(:value, :label, keyword_init: true)

    def initialize(form:, offer_wizard:, radio_options: {})
      @form = form
      @offer_wizard = offer_wizard
      @radio_options = radio_options
    end

    def options
      SkeCondition::SKE_LENGTHS.map do |value|
        SkeLength.new(value: value, label: "#{value} weeks")
      end
    end

    def radio_options(ske_condition)
      if @offer_wizard.language_course? && @offer_wizard.ske_conditions.many?
        {
          legend: {
            text: t(
              'provider_interface.offer.ske_lengths.form.title_language',
              language: ske_condition.subject,
            ),
          },
        }
      else
        @radio_options
      end
    end
  end
end
