module SupportInterface
  class TileComponent < ViewComponent::Base
    attr_reader :count, :label, :colour

    def initialize(count:, label:, colour: :default, size: :regular)
      @count = count
      @label = label
      @colour = colour
      @size = size
    end

    def count_class
      @size == :regular ? 'app-card__count' : 'app-card__secondary-count'
    end
  end
end
