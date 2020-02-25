module SupportInterface
  class TileComponent < ActionView::Component::Base
    attr_reader :count, :label

    def initialize(count:, label:)
      @count = count
      @label = label
    end
  end
end
