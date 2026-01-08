class ProviderInterface::LocationFilterComponent < BaseComponent
  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end
end
