module ProviderInterface
  class ConditionsListComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def empty_conditions
      render ConditionsListComponent.new([])
    end

    def conditions_list
      conditions = rand(1..3).times.map { FactoryBot.build_stubbed(:offer_condition, status: %w[pending met unmet].sample) }
      render ConditionsListComponent.new(conditions)
    end
  end
end
