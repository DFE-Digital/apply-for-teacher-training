module SupportInterface
  class TileComponent < ViewComponent::Base
    attr_reader :count, :label, :colour, :href

    def initialize(count:, label:, colour: :default, size: :regular, href: nil)
      @count = count
      @label = label
      @colour = colour
      @size = size
      @href = href
    end

    def card_classes
      colour == :default ? 'app-card' : "app-card app-card--#{colour}"
    end

    def count_class
      @size == :regular ? 'app-card__count' : 'app-card__secondary-count'
    end
  end
end
