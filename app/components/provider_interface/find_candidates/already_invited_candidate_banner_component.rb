class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent < ViewComponent::Base
  delegate :provider, to: :invite
  delegate :course, to: :invite

  def initialize(application_form:, current_provider_user:, show_provider_name:)
    @application_form = application_form
    @current_provider_user = current_provider_user
    @show_provider_name = show_provider_name
  end

  def render?
    invite.present?
  end

  def heading
    key = @show_provider_name ? 'heading_with_provider' : 'heading_without_provider'
    I18n.t("provider_interface.find_candidates.already_invited_candidate_banner_component.#{key}",
           subject: course.name,
           provider: provider.name)
  end

  def text
    key = @show_provider_name ? 'text_with_provider' : 'text_without_provider'
    I18n.t("provider_interface.find_candidates.already_invited_candidate_banner_component.#{key}",
           subject: course.name_and_code,
           provider: provider.name,
           date: date)
  end

  def date
    invite.created_at.to_fs(:govuk_date)
  end

private

  def invite
    @invite ||= Pool::Invite.find_by(
      provider_id: @current_provider_user.provider_ids,
      candidate_id: @application_form.candidate_id,
      status: :published,
    )
  end
end
