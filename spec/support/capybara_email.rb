require 'capybara/email/rspec'

# mail-notify >= 2.0 renders a view mailer into `message.personalisation[:body]`
# (that is what gets sent to the Notify API)
# so to keep our specs working we need some logic for methods like
# current_email.text and find_css('a') to still work

module CapybaraEmailNotifyBody
  def notify_body
    email.respond_to?(:personalisation) ? email.personalisation&.[](:body) : nil
  end

  def raw
    body = notify_body

    return body if body.present?

    super
  end

  def source
    body = notify_body

    return convert_to_html(body) if body.present?

    super
  end
end

Capybara::Email::Driver.prepend(CapybaraEmailNotifyBody)
