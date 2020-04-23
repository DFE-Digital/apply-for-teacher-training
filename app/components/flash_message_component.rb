class FlashMessageComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

private

  attr_reader :flash
end
