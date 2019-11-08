module ViewHelper
  def govuk_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url, body = 'Back')
    link_to(body, url, class: 'govuk-back-link')
  end

  def bat_contact_mail_to(name = nil, html_options: {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    mail_to('becomingateacher@digital.education.gov.uk', name, html_options)
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-button', html_options[:class])

    link_to(body, url, role: 'button', class: html_options[:class], 'data-module': 'govuk-button', draggable: false)
  end

  def select_nationality_options
    [
      OpenStruct.new(id: '', name: t('application_form.personal_details.nationality.default_option')),
    ] + NATIONALITIES.map { |_, nationality| OpenStruct.new(id: nationality, name: nationality) }
  end

  def select_gcse_qualification_type_options
    option = Struct.new(:id, :label)
    [
      [:gcse, 'GCSE'],
      [:gce_o_level, 'GCE O Level'],
      [:scottish_higher, 'Scottish Higher'],
      [:other_uk, 'Other UK qualification'],
    ].map { |id, label| option.new(id, label) }
  end

private

  def prepend_css_class(css_class, current_class)
    if current_class
      current_class.prepend("#{css_class} ")
    else
      css_class
    end
  end
end
