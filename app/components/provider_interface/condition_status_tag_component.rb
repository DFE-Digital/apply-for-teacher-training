module ProviderInterface
  class ConditionStatusTagComponent < ApplicationComponent
    attr_reader :condition

    def initialize(condition)
      @condition = condition
    end
  end
end
