module SupportInterface
  class TileComponent < ActionView::Component::Base
    attr_reader :count, :label, :colour

    def initialize(count:, label:, colour: :grey)
      @count = count
      @label = label
      @colour = colour
    end
  end
end
