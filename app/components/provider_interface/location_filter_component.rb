class ProviderInterface::LocationFilterComponent < ViewComponent::Base
  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end
end
