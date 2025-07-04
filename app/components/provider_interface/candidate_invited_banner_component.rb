class ProviderInterface::CandidateInvitedBannerComponent < ViewComponent::Base
  delegate :course, to: :matching_invite

  def initialize(application_choice:, current_provider_user:)
    @application_choice = application_choice
    @application_form = application_choice.application_form
    @current_provider_user = current_provider_user
  end

  def render?
    matching_invite.present?
  end

  def inviting_organisation
    matching_invite.provider_name
  end

  def date
    matching_invite.created_at.to_fs(:govuk_date)
  end

private

  def invites
    @invites ||= Pool::Invite.published.where(
      provider_id: @current_provider_user.provider_ids,
      application_form: @application_form,
    ).includes(:course, :provider)
  end

  def matching_invite
    invites.find do |invite|
      invite.matching_application_choice == @application_choice
    end
  end
end
