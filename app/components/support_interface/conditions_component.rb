module SupportInterface
  class ConditionsComponent < ViewComponent::Base
    attr_accessor :conditions

    def initialize(conditions:)
      @conditions = conditions
    end
  end
end
