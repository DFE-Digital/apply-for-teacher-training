module ViewHelper
  include DfE::Autocomplete::ApplicationHelper

  def govuk_back_link_to(url = :back, body = 'Back', force_text: false)
    classes = 'govuk-!-display-none-print'

    url = back_link_url if url == :back

    text = if force_text.present?
             body
           elsif url.to_s.end_with?(candidate_interface_details_path)
             'Back to your details'
           elsif url.to_s.end_with?(candidate_interface_application_choices_path)
             'Back to your applications'
           end

    text ||= body

    render GovukComponent::BackLinkComponent.new(
      text: text,
      href: url,
      classes:,
    )
  end

  def breadcrumbs(breadcrumbs)
    render GovukComponent::BreadcrumbsComponent.new(
      breadcrumbs:,
      hide_in_print: true,
    )
  end

  def break_email_address(email_address)
    email_address.gsub(/@/, '<wbr>@').html_safe
  end

  def bat_contact_mail_to(name = 'becomingateacher<wbr>@digital.education.gov.uk', html_options: {})
    govuk_mail_to('becomingateacher@digital.education.gov.uk', name.html_safe, **html_options)
  end

  def submitted_at_date
    dates = ApplicationDates.new(@application_form)
    return if dates.submitted_at.nil?

    dates.submitted_at.to_fs(:govuk_date).strip
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def title_with_success_prefix(title, success)
    "#{t('page_titles.success_prefix') if success}#{title}"
  end

  def format_months_to_years_and_months(number_of_months)
    duration_parts = ActiveSupport::Duration.build(number_of_months.months).parts

    if duration_parts[:years] && duration_parts[:months]
      "#{pluralize(duration_parts[:years], 'year')} and #{pluralize(duration_parts[:months], 'month')}"
    elsif duration_parts[:years]
      pluralize(duration_parts[:years], 'year')
    else
      pluralize(number_of_months, 'month')
    end
  end

  def days_since(days)
    return unless days.is_a?(Integer)

    if days.zero?
      'today'
    else
      "#{pluralize(days, 'day')} ago"
    end
  end

  def boolean_to_word(boolean)
    return nil if boolean.nil?

    boolean ? 'Yes' : 'No'
  end

  def percent_of(numerator, denominator)
    numerator.to_f / denominator * 100.0
  end

  def formatted_percentage(count, total)
    return '-' if total.zero? && count.positive?
    return '0%' if total.zero?

    percentage = percent_of(count, total)
    precision = (percentage % 1).zero? ? 0 : 2
    number_to_percentage(percentage, precision:, strip_insignificant_zeros: true)
  end

  def protect_against_mistakes(anchor:)
    if session[:confirmed_environment_at] && session[:confirmed_environment_at] > 5.minutes.ago
      yield
    else
      govuk_link_to 'Confirm environment to make changes', support_interface_confirm_environment_path(from: [request.fullpath, anchor].join('#'))
    end
  end

  delegate :application_form_path, to: :BackLinks

private

  def back_link_url
    referer = controller.request.env['HTTP_REFERER']

    if referer
      referer_host = URI(referer).host
      if referer_host.present? && referer_host != request.host
        service_link
      else
        referer
      end
    else
      service_link
    end
  end
end
