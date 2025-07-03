class ProviderInterface::FindCandidates::ApplicationChoicesComponent < ViewComponent::Base
  attr_reader :application_form, :provider_user

  def initialize(application_form:, provider_user:)
    @application_form = application_form
    @provider_user = provider_user
  end

  def application_choice_rows(choice)
    [
      provider(choice),
      application_number(choice),
      course_subject(choice),
      status(choice),
      withdrawal_reason(choice),
      rejection_reason(choice),
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

  def provider(choice)
    return unless provider_user.providers.include?(choice.provider)

    {
      key: { text: t('.provider') },
      value: { text: choice.provider.name },
    }
  end

  def application_number(choice)
    return unless provider_user.providers.include?(choice.provider)

    {
      key: { text: t('.application_number') },
      value: { text: govuk_link_to(choice.id, provider_interface_application_choice_path(choice)) },
    }
  end

  def course_subject(choice)
    subject_names = choice.course.subjects.pluck(:name).to_sentence

    {
      key: { text: t('.subject') },
      value: { text: provider_user.providers.include?(choice.provider) ? "#{subject_names} (#{choice.course.code})" : subject_names },
    }
  end

  def status(choice)
    return unless provider_user.providers.include?(choice.provider)

    {
      key: { text: t('.status') },
      value: { text: render(ProviderInterface::ApplicationStatusTagComponent.new(application_choice: choice)) },
    }
  end

  def withdrawal_reason(choice)
    return unless provider_user.providers.include?(choice.provider) && choice.withdrawn?

    {
      key: { text: t('.withdrawal_reason') },
      value: { text: 'tbc' },
      # value: { text: render(WithdrawalReasons::FormattedTextComponent.new(application_choice: choice)) },
    }
  end

  def rejection_reason(choice)
    return unless provider_user.providers.include?(choice.provider) && choice.rejected?

    {
      key: { text: t('.rejection_reason') },
      value: { text: render(RejectionReasons::FormattedTextComponent.new(application_choice: choice)) },
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
