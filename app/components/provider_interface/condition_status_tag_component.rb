module ProviderInterface
  class ConditionStatusTagComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :condition

    def initialize(condition)
      @condition = condition
    end
  end
end
