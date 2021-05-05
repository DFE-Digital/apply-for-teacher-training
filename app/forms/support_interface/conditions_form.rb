module SupportInterface
  class ConditionsForm
    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :further_conditions

    NUMBER_OF_FURTHER_CONDITIONS = 4
    validates :application_choice, presence: true

    def self.build_from_application_choice(application_choice)
      attrs = {
        application_choice: application_choice,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_conditions: further_conditions_from(application_choice.offer),
      }

      new(attrs).tap do |form|
        form.setup_further_conditions
      end
    end

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer['conditions']
      conditions & MakeAnOffer::STANDARD_CONDITIONS
    end

    def self.further_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer['conditions']
      conditions - MakeAnOffer::STANDARD_CONDITIONS
    end

    def setup_further_conditions
      self.further_conditions = NUMBER_OF_FURTHER_CONDITIONS.times.map do |index|
        existing_value = further_conditions && further_conditions[index]
        existing_value.presence || ''
      end
    end

    def further_condition_models
      @further_condition_models ||= further_conditions.map.with_index do |further_condition, index|
        ProviderInterface::OfferConditionField.new(id: index, text: further_condition)
      end
    end

    def save
      raise 'TODO'
    end
  end
end
