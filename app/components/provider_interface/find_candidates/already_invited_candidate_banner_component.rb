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

  def heading
    if invite.declined?
      t('provider_interface.find_candidates.already_invited_candidate_banner_component.declined_heading', subject: invite.course.name_and_code)
    else
      t('provider_interface.find_candidates.already_invited_candidate_banner_component.heading', subject: invite.course.name, provider: invite.provider.name, count: @current_provider_user.providers.count)
    end
  end

  def text
    if invite.matching_application_choice
      t(
        'provider_interface.find_candidates.already_invited_candidate_banner_component.text_with_application_html',
        link: view_application_link(invite),
      )
    elsif invite.declined?
      t('provider_interface.find_candidates.already_invited_candidate_banner_component.declined_text',
        reason: format_decline_reason(invite.invite_decline_reasons.first.reason))
    else
      t(
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

  def format_decline_reason(reason_key)
    reason_text = I18n.t("candidate_interface.decline_reasons.new.reasons.#{reason_key}")

    unless reason_text.start_with?('I')
      reason_text = reason_text.sub(/\A\p{L}/, &:downcase)
    end

    reason_text
  end

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
      t('provider_interface.find_candidates.already_invited_candidate_banner_component.view_application'),
      provider_interface_application_choice_path(choice),
    )
  end
end
