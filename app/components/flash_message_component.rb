class FlashMessageComponent < ActionView::Component::Base
  validates :flash, presence: true

  def initialize(flash:)
    @flash = flash
  end

private

  attr_reader :flash
end
