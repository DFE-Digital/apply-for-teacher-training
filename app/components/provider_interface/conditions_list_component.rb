module ProviderInterface
  class ConditionsListComponent < ApplicationComponent
    attr_reader :conditions

    def initialize(conditions)
      @conditions = sorted_conditions(conditions)
    end

  private

    def sorted_conditions(conditions)
      conditions.sort_by { |c| [OfferCondition::STANDARD_CONDITIONS.index(c.text) || Float::INFINITY, c.created_at] }
    end
  end
end
