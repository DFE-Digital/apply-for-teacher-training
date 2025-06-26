class ProviderInterface::FindCandidates::CandidateInvitedBannerComponent < ViewComponent::Base
  delegate :course, to: :invite

  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    invite.present?
  end

  def inviting_organisation
    invite.provider_name
  end

  def date
    invite.created_at.to_fs(:govuk_date)
  end

private

  def invite
    @invite ||= Pool::Invite.published.find_by(
      provider_id: @current_provider_user.provider_ids,
      candidate_id: @application_form.candidate_id,
    )
  end
end
