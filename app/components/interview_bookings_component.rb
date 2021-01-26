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
    make_urls_clickable(
      show_newlines(
        interview.location,
      ),
    )
  end

  def additional_details(interview)
    make_urls_clickable(
      show_newlines(
        interview.additional_details,
      ),
    )
  end

private

  def show_newlines(text)
    simple_format(text, class: 'govuk-body')
  end

  def make_urls_clickable(text)
    text
      .yield_self { |t| t.gsub(URI::DEFAULT_PARSER.make_regexp, '<a href="\0">\0</a>') }
      .then(&:html_safe)
      .then { |t| sanitize(t, tags: %w[a p br]) }
  end
end
