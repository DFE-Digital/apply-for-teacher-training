class NotificationMessageComponent < ViewComponent::Base
  include ViewHelper

  def initialize(notification_type, message:, secondary_message: nil, message_link: nil)
    @notification_type = notification_type
    @notification_heading = message
    @notification_message = secondary_message
    @notification_message_link = message_link
  end

  def title
    I18n.t(notification_type, scope: :notification_banner)
  end

  def heading
    return unless notification_heading.is_a?(String)

    @heading ||= ApplicationController.renderer.render(inline: notification_heading)
  end

  def message
    @message ||= ApplicationController.renderer.render(inline: notification_message)
  end

  def link
    return if notification_message_link.blank?

    @link ||= Struct.new(:text, :url).new(notification_message_link['text'], notification_message_link['url'])
  end

  def role
    %i[warning success].include?(notification_type) ? 'alert' : 'region'
  end

private

  attr_reader :notification_type, :notification_heading, :notification_message, :notification_message_link
end
