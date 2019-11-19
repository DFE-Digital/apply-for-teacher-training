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

  def submitted_at_date
    dates = ApplicationDates.new(@application_form)
    dates.submitted_at.strftime('%e %B %Y')
  end

  def respond_by_date
    dates = ApplicationDates.new(@application_form)
    dates.respond_by.strftime('%e %B %Y')
  end

  def edit_by_date
    dates = ApplicationDates.new(@application_form)
    dates.edit_by.strftime('%e %B %Y')
  end

  def formatted_days_remaining
    dates = ApplicationDates.new(@application_form)
    pluralize(dates.days_remaining_to_edit, 'day')
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
