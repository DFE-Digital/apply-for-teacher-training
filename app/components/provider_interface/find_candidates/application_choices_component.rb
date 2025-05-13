class ProviderInterface::FindCandidates::ApplicationChoicesComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def application_choice_rows(choice)
    [
      course_subject(choice),
      location(choice),
      qualification(choice),
      funding_type(choice),
      study_mode(choice),
      date_submitted(choice),
    ].compact
  end

  def application_choices
    @application_choices ||= application_form
                               .application_choices
                               .where.not(sent_to_provider_at: nil)
                               .order(:sent_to_provider_at)
                               .reverse
  end

private

  def course_subject(choice)
    {
      key: { text: t('.subject') },
      value: { text: choice.course.subjects.pluck(:name).to_sentence },
    }
  end

  def location(choice)
    site = choice.course_option.site
    {
      key: { text: t('.location') },
      value: { text: "#{site.address_line2} #{site.address_line3}" },
    }
  end

  def qualification(choice)
    {
      key: { text: t('.qualification') },
      value: { text: choice.course.qualifications_to_s },
    }
  end

  def funding_type(choice)
    {
      key: { text: t('.funding_type') },
      value: { text: choice.course.funding_type.capitalize },
    }
  end

  def study_mode(choice)
    {
      key: { text: t('.study_mode') },
      value: { text: choice.course_option.study_mode.humanize.to_s },
    }
  end

  def date_submitted(choice)
    {
      key: { text: t('.date_submitted') },
      value: { text: choice.sent_to_provider_at.to_fs(:govuk_date) },
    }
  end
end
