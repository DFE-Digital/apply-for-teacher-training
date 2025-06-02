module CandidateInterface
  class PoolInvitesController < CandidateInterfaceController
    before_action :set_invite, only: [:show]

    def index
      @invites = current_candidate.pool_invites.published
    end

    def show
      @invite.candidate_invite_status_viewed! if @invite.candidate_invite_status_new?
      redirect_to @invite.course.find_url, allow_other_host: true
    end

  private

    def set_invite
      @invite ||= current_candidate.pool_invites.published.find_by(id: params.expect(:id))
    end
  end
end
