module ProviderInterface
  class ConditionStatusTagComponent < ViewComponent::Base
    attr_reader :condition

    def initialize(condition)
      @condition = condition
    end
  end
end
