class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent < ViewComponent::Base
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
           subject: invite.course.name,
           provider: invite.provider.name)
  end

  def text
    if matching_application_choice(invite)
      I18n.t(
        'provider_interface.find_candidates.already_invited_candidate_banner_component.text_with_application',
        link: view_application_link(invite),
      ).html_safe
    else
      key = @show_provider_name ? 'text_with_provider' : 'text_without_provider'
      I18n.t(
        "provider_interface.find_candidates.already_invited_candidate_banner_component.#{key}",
        subject: invite.course.name_and_code,
        provider: invite.provider.name,
        date: date,
      )
    end
  end

  def date
    invite.created_at.to_fs(:govuk_date)
  end

private

  def invites
    @invites ||= Pool::Invite.published
      .where(
        provider_id: @current_provider_user.provider_ids,
        candidate_id: @application_form.candidate_id,
      )
      .includes(:course, :provider)
  end

  def matching_application_choice(invite)
    @application_form.application_choices
      .visible_to_provider
      .find { |choice| choice.course.code == invite.course.code }
  end

  def view_application_link(invite)
    choice = matching_application_choice(invite)
    return unless choice

    govuk_link_to(
      I18n.t('provider_interface.find_candidates.already_invited_candidate_banner_component.view_application'),
      provider_interface_application_choice_path(choice),
    )
  end
end
