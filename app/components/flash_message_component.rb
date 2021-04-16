class FlashMessageComponent < ViewComponent::Base
  ALLOWED_PRIMARY_KEYS = %i[info warning success].freeze

  def initialize(flash:)
    @flash = flash
  end

  def message_key
    flash.keys.detect { |key| ALLOWED_PRIMARY_KEYS.include?(key.to_sym) }
  end

  def title
    I18n.t(message_key, scope: :notification_banner)
  end

  def classes
    "govuk-notification-banner--#{message_key}"
  end

  def role
    %i[warning success].include?(message_key) ? 'alert' : 'region'
  end

  def disable_auto_focus
    message_key == 'info'
  end

  def heading
    messages.is_a?(Array) ? messages[0] : messages
  end

  def body
    if messages.is_a?(Array) && messages.count >= 2
      tag.p(messages[1], class: 'govuk-body')
    end
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
