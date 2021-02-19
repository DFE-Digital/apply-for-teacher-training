module SupportInterface
  class TileComponentPreview < ViewComponent::Preview
    def regular_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice')
    end

    def blue_headline_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice', colour: :blue)
    end

    def green_success_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice', colour: :green)
    end

    def red_error_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice', colour: :red)
    end

    def secondary_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice', size: :secondary)
    end

    def linked_tile
      render SupportInterface::TileComponent.new(count: 3, label: 'blind mice', href: '#')
    end
  end
end
