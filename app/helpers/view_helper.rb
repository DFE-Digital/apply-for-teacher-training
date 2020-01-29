module ViewHelper
  def govuk_link_to(body, url, html_options = {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url, body = 'Back')
    link_to(body, url, class: 'govuk-back-link')
  end

  def bat_contact_mail_to(name = 'becomingateacher<wbr>@digital.education.gov.uk', html_options: {})
    html_options[:class] = prepend_css_class('govuk-link', html_options[:class])

    mail_to('becomingateacher@digital.education.gov.uk', name.html_safe, html_options)
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

  def select_course_options(courses)
    [
      OpenStruct.new(id: '', name: t('activemodel.errors.models.candidate_interface/pick_course_form.attributes.code.blank')),
    ] + courses.map { |course| OpenStruct.new(id: course.code, name: "#{course.name} (#{course.code})") }
  end

  def submitted_at_date
    dates = ApplicationDates.new(@application_form)
    dates.submitted_at.to_s(:govuk_date).strip
  end

  def respond_by_date
    dates = ApplicationDates.new(@application_form)
    dates.reject_by_default_at.to_s(:govuk_date).strip if dates.reject_by_default_at
  end

  def formatted_days_remaining
    dates = ApplicationDates.new(@application_form)
    pluralize(dates.days_remaining_to_edit, 'day')
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def title_with_success_prefix(title, success)
    "#{t('page_titles.success_prefix') if success}#{title}"
  end

  def edit_by_date
    dates = ApplicationDates.new(@application_form)
    dates.edit_by.to_s(:govuk_date).strip
  end

  def candidate_sign_in_url(candidate)
    encrypted_candidate_id = Encryptor.encrypt(candidate.id)

    if FeatureFlag.active?('improved_expired_token_flow')
      candidate_interface_sign_in_url(u: encrypted_candidate_id)
    else
      candidate_interface_sign_in_url
    end
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
