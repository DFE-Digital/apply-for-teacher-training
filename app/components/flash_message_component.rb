class FlashMessageComponent < ViewComponent::Base
  ALLOWED_PRIMARY_KEYS = %i[info warning success].freeze

  def initialize(flash:)
    @flash = flash
  end

  def message_key
    flash.keys.detect { |key| ALLOWED_PRIMARY_KEYS.include?(key.to_sym) }
  end

  def message
    messages.is_a?(Array) ? messages[0] : messages
  end

  def secondary_message
    messages.is_a?(Array) && messages.count >= 2 ? messages[1] : nil
  end

  def render?
    !flash.empty? && message_key
  end

private

  def messages
    flash[message_key]
  end

  attr_reader :flash
end
