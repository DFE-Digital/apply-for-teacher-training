class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    invites.size > 1
  end

  def invite_details
    invites.map do |invite|
      if invite.matching_application_choice(@application_form)
        I18n.t(
          'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.text_with_application',
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
          link: view_application_link(invite),
        ).html_safe
      else
        I18n.t(
          'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.text',
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
          count: @current_provider_user.providers.count,
        )
      end
    end
  end

private

  def invites
    @invites ||= Pool::Invite.published.where(
      provider_id: @current_provider_user.provider_ids,
      candidate_id: @application_form.candidate_id,
    ).includes(:course, :provider)
  end

  def view_application_link(invite)
    choice = invite.matching_application_choice(@application_form)
    return unless choice

    govuk_link_to(I18n.t(
                    'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.view_application',
                  ), provider_interface_application_choice_path(choice))
  end
end
