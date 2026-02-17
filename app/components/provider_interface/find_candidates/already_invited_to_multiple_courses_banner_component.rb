class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent < ApplicationComponent
  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    invites.size > 1
  end

  def invite_details
    invites.map do |invite|
      if invite.matching_application_choice
        t(
          'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.text_with_application_html',
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
          link: view_application_link(invite),
        )
      elsif invite.declined?
        t(
          'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.declined_text',
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
          count: @current_provider_user.providers.count,
        )
      else
        t(
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
      application_form: @application_form,
    ).includes(:course, :provider)
  end

  def view_application_link(invite)
    choice = invite.matching_application_choice
    return unless choice

    govuk_link_to(t(
                    'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.view_application',
                  ), provider_interface_application_choice_path(choice))
  end
end
