module ProviderInterface
  class ConditionStatusTagComponent < BaseComponent
    attr_reader :condition

    def initialize(condition)
      @condition = condition
    end
  end
end
