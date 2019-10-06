module ViewHelper
  def govuk_link_to(body, url, html_options = {})
    html_options[:class] = prepend_link_class(html_options[:class])

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url)
    link_to('Back', url, class: 'govuk-back-link')
  end

  def bat_contact_mail_to(name = nil, html_options: {})
    html_options[:class] = prepend_link_class(html_options[:class])

    mail_to('becomingateacher@digital.education.gov.uk', name, html_options)
  end

private

  def prepend_link_class(link_class)
    if link_class
      link_class.prepend('govuk-link ')
    else
      'govuk-link'
    end
  end
end
