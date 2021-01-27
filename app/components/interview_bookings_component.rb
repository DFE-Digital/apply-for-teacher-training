# frozen_string_literal: true

class InterviewBookingsComponent < ViewComponent::Base
  def initialize(application_choice)
    @application_choice = application_choice
  end

  def interviews
    @application_choice.interviews.includes(:provider).order(date_and_time: :asc)
  end

  def formatted_time(interview)
    interview.date_and_time.to_s(:govuk_date_and_time).squish
  end

  def provider_name(interview)
    interview.provider.name
  end

  def location(interview)
    safely_format_with_hyperlinks(interview.location)
  end

  def additional_details(interview)
    safely_format_with_hyperlinks(interview.additional_details)
  end

private

  def safely_format_with_hyperlinks(text)
    text
      .then { |t| simple_format(t, class: 'govuk-body') } # Sanitizes text before handling newlines
      .then { |t| t.gsub(URI::DEFAULT_PARSER.make_regexp(%w[http https]), '<a href="\0">\0</a>') }
      .then(&:html_safe)
  end
end
