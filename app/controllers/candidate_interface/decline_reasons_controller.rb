module CandidateInterface
  class DeclineReasonsController < CandidateInterfaceController
    before_action :set_invite, only: %i[new create]

    def new
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new
    end

    def create
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new(fac_invite_decline_reason_form_params)

      if @fac_invite_decline_reason_form.save(@invite)
        flash[:success] = [
          t('.header', course: @invite.course.name_and_code,
                       provider: @invite.provider_name),
          CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent.new(invite: @invite).render_in(view_context),
        ]

        redirect_to candidate_interface_invites_path
      else
        track_validation_error(@fac_invite_decline_reason_form)
        render :new, status: :unprocessable_entity
      end
    end

  private

    def set_invite
      @invite = Pool::Invite.find(params.expect(:invite_id))
    end

    def fac_invite_decline_reason_form_params
      params.fetch(:candidate_interface_fac_invite_decline_reasons_form, {}).permit(:comment, reasons: [])
    end
  end
end
