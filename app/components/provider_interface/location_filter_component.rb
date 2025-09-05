class ProviderInterface::LocationFilterComponent < ApplicationComponent
  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end
end
