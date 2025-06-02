module CandidateInterface
  class RejectInvitesController < CandidateInterfaceController
    def new
      @invite = invite
      @rejection = CandidateInterface::RejectInviteForm.new
    end

    def create
      @rejection = CandidateInterface::RejectInviteForm.new(
        invite:,
        rejection_reason: reject_params[:rejection_reason],
      )

      if @rejection.save
        flash[:success] = "You have rejected an invite for #{@invite.course.name}"
        redirect_to candidate_interface_pool_invites_path
      else
        render :new
      end
    end

  private

    def invite
      @invite ||= current_candidate.pool_invites.published.find_by(id: params.expect(:pool_invite_id))
    end

    def reject_params
      params.expect(candidate_interface_reject_invite_form: [:rejection_reason])
    end
  end
end
