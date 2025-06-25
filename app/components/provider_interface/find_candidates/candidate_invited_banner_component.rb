class ProviderInterface::FindCandidates::CandidateInvitedBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    show_candidate_invited_banner?
  end

  def course
    Course.find(invite.course_id)
  end

  def inviting_organisation
    @provider = Provider.find(@invite.provider_id)

    @provider.name
  end

  def date
    invite.created_at.to_fs(:govuk_date)
  end

  def show_candidate_invited_banner?
    invite.present? && invite.status == 'published'
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
