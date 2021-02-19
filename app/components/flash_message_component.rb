class FlashMessageComponent < ViewComponent::Base
  ALLOWED_PRIMARY_KEYS = %i[info warning success].freeze

  def initialize(flash:)
    @flash = flash
  end

  def message_key
    flash.keys.detect { |key| ALLOWED_PRIMARY_KEYS.include?(key.to_sym) }
  end

  def render?
    !flash.empty? && message_key
  end

private

  attr_reader :flash
end
