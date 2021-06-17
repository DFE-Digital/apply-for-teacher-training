module ProviderInterface
  class ConditionsListComponent < ViewComponent::Base
    attr_reader :conditions

    def initialize(conditions)
      @conditions = conditions
    end
  end
end
