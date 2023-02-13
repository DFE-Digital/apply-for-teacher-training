module ProviderInterface
  class SkeLengthComponent < ViewComponent::Base
    attr_reader :form, :offer_wizard, :radio_options

    def initialize(form:, offer_wizard:, radio_options: {})
      @form = form
      @offer_wizard = offer_wizard
      @radio_options = radio_options
    end

    def options
      ProviderInterface::OfferWizard::SKE_LENGTH.map do |value|
        OpenStruct.new(value: value, label: "#{value} weeks")
      end
    end
  end
end
