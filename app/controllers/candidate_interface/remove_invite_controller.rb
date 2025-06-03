module CandidateInterface
  class RemoveInviteController < CandidateInterfaceController
    before_action :set_invite
    def new; end

    def create
      @invite.candidate_invite_status_removed!
      flash[:success] = "#{@invite.course.name_and_code} invitation removed"
      redirect_to candidate_interface_pool_invites_path
    end

  private

    def set_invite
      @invite ||= current_candidate.pool_invites.published.find_by(id: params.expect(:pool_invite_id))
    end
  end
end
