module ViewHelper
  def govuk_link_to(body, url, html_options = {})
    if html_options[:class]
      html_options[:class].prepend('govuk-link ')
    else
      html_options[:class] = 'govuk-link'
    end

    link_to(body, url, html_options)
  end
end
