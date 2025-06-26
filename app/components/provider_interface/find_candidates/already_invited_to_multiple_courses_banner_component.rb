class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:, show_provider_name:)
    @application_form = application_form
    @current_provider_user = current_provider_user
    @show_provider_name = show_provider_name
  end

  def render?
    invites.size > 1 && !application_received_for_any_invited_course?
  end

  def heading
    I18n.t('provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.heading')
  end

  def invite_details
    key = @show_provider_name ? 'text_with_provider' : 'text_without_provider'

    invites.map do |invite|
      I18n.t(
        "provider_interface.find_candidates.already_invited_to_multiple_courses_banner_component.#{key}",
        course: invite.course.name_and_code,
        provider: invite.provider.name,
        date: invite.created_at.to_fs(:govuk_date),
      )
    end
  end

private

  def invites
    @invites ||= Pool::Invite.published.where(
      provider_id: @current_provider_user.provider_ids,
      candidate_id: @application_form.candidate_id,
    ).includes(:course, :provider)
  end

  def application_received_for_any_invited_course?
    invited_course_codes = invites.map { |invite| invite.course.code }.compact.uniq
    @application_form.application_choices.any? do |choice|
      invited_course_codes.include?(choice.course.code)
    end
  end
end
