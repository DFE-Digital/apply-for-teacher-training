class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:, show_provider_name:)
    @application_form = application_form
    @current_provider_user = current_provider_user
    @show_provider_name = show_provider_name
  end

  def render?
    invites.size > 1
  end

  def heading
    I18n.t('provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.heading')
  end

  def invite_details
    invites.map do |invite|
      if matching_application_choice(invite)
        I18n.t(
          'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.text_with_application',
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
          link: view_application_link(invite),
        ).html_safe
      else
        key = @show_provider_name ? 'text_with_provider' : 'text_without_provider'

        I18n.t(
          "provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.#{key}",
          course: invite.course.name_and_code,
          provider: invite.provider.name,
          date: invite.created_at.to_fs(:govuk_date),
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

  def matching_application_choice(invite)
    @application_form.application_choices
      .visible_to_provider
      .find { |choice| choice.course.code == invite.course.code }
  end

  def view_application_link(invite)
    choice = matching_application_choice(invite)
    return unless choice

    govuk_link_to(I18n.t(
                    'provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.view_application',
                  ), provider_interface_application_choice_path(choice))
  end
end
