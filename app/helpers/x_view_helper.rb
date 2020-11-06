module XViewHelper
  def govuk_mail_to(email, name = nil, html_options = {}, &block)
    mail_to(email, name, html_options.merge(class: "govuk-link"), &block)
  end

  def govuk_link_to(body, url = body, html_options = { class: "govuk-link" })
    link_to body, url, html_options
  end

  def govuk_back_link_to(url, link_text = "Back")
    govuk_link_to(link_text, url, class: "govuk-back-link", data: { qa: "page-back" })
  end

  def permitted_referrer?
    return false if request.referer.blank?

    request.referer.include?(request.host_with_port) ||
      Settings.valid_referers.any? { |url| request.referer.start_with?(url) }
  end

  def bat_contact_email_address
    Settings.service_support.contact_email_address
  end

  def bat_contact_mail_to(name = nil, subject: nil, link_class: "govuk-link")
    mail_to bat_contact_email_address, name || bat_contact_email_address, subject: subject, class: link_class
  end
end
