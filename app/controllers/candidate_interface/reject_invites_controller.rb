module CandidateInterface
  class RejectInvitesController < CandidateInterfaceController
    def new
      @invite = invite
      @rejection = CandidateInterface::RejectInviteForm.new
    end

    def create
      @rejection = CandidateInterface::RejectInviteForm.new(
        invite:,
        dismiss_reason: reject_params[:dismiss_reason],
        dismiss_text: reject_params[:dismiss_text],
      )

      if @rejection.save
        flash[:success] = "You have dismissed an invite for #{@invite.course.name}"
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
      params.expect(
        candidate_interface_reject_invite_form: %i[
          dismiss_reason
          dismiss_text
        ],
      )
    end
  end
end
