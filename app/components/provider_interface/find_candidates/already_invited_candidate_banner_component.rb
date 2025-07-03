class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    invites.one?
  end

  def invite
    invites.first
  end

  def text
    if invite.matching_application_choice
      I18n.t(
        'provider_interface.find_candidates.already_invited_candidate_banner_component.text_with_application',
        link: view_application_link(invite),
      ).html_safe
    else
      I18n.t(
        'provider_interface.find_candidates.already_invited_candidate_banner_component.text',
        subject: invite.course.name_and_code,
        provider: invite.provider.name,
        date: date,
        count: @current_provider_user.providers.count,
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
        application_form: @application_form,
      )
      .includes(:course, :provider)
  end

  def view_application_link(invite)
    choice = invite.matching_application_choice
    return unless choice

    govuk_link_to(
      I18n.t('provider_interface.find_candidates.already_invited_candidate_banner_component.view_application'),
      provider_interface_application_choice_path(choice),
    )
  end
end
