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
      colour == :default ? 'app-card govuk-!-margin-bottom-4' : "app-card app-card--#{colour} govuk-!-margin-bottom-4"
    end

    def count_class
      @size == :regular ? 'app-card__count' : 'app-card__secondary-count'
    end
  end
end
