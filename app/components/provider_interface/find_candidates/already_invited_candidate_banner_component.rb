class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent < ViewComponent::Base
  delegate :course, to: :invite
  delegate :provider, to: :invite

  def initialize(application_form:, current_provider_user:, show_provider_name:)
    @application_form = application_form
    @current_provider_user = current_provider_user
    @show_provider_name = show_provider_name
  end

  def render?
    invites.one?
  end

  def invite
    invites.first
  end

  def heading
    key = @show_provider_name ? 'heading_with_provider' : 'heading_without_provider'
    I18n.t("provider_interface.find_candidates.already_invited_candidate_banner_component.#{key}",
           subject: course.name,
           provider: provider.name)
  end

  def text
    if matching_application_choice
      I18n.t(
        'provider_interface.find_candidates.already_invited_candidate_banner_component.text_with_application',
        link: view_application_link,
      ).html_safe
    else
      key = @show_provider_name ? 'text_with_provider' : 'text_without_provider'
      I18n.t(
        "provider_interface.find_candidates.already_invited_candidate_banner_component.#{key}",
        subject: course.name_and_code,
        provider: provider.name,
        date: date,
      )
    end
  end

  def date
    invite.created_at.to_fs(:govuk_date)
  end

  def view_application_link
    govuk_link_to('View application', provider_interface_application_choice_path(matching_application_choice))
  end

private

  def invites
    @invites ||= Pool::Invite.published.where(
      provider_id: @current_provider_user.provider_ids,
      candidate_id: @application_form.candidate_id,
    ).includes(:course, :provider)
  end

  def matching_application_choice
    @application_form.application_choices.find do |choice|
      choice.course.code == course.code
    end
  end
end
