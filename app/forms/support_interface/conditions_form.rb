module SupportInterface
  class ConditionsForm
    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :further_conditions

    NUMBER_OF_FURTHER_CONDITIONS = 4
    validates :application_choice, presence: true

    def initialize(attrs)
      setup_further_conditions
      super
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
