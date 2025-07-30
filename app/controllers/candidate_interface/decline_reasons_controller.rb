module CandidateInterface
  class DeclineReasonsController < CandidateInterfaceController
    before_action :set_invite, only: %i[new create]

    def new
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new
    end

    def create
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new(fac_invite_decline_reason_form_params)

      if @fac_invite_decline_reason_form.valid?
        @fac_invite_decline_reason_form.save(@invite)
        flash[:success] = [t('.header', course: @invite.course.name_and_code,
                                        provider: @invite.provider_name),
                           t('.body', link: view_context.govuk_link_to('apply to this course',
                                                                       candidate_interface_course_choices_course_confirm_selection_path(@invite.course),
                                                                       class: 'govuk-notification-banner__link'))]

        redirect_to candidate_interface_invites_path
      else
        track_validation_error(@fac_invite_decline_reason_form)
        render :new
      end
    end

  private

    def set_invite
      @invite = Pool::Invite.find(params[:invite_id])
    end

    def fac_invite_decline_reason_form_params
      params.fetch(:candidate_interface_fac_invite_decline_reasons_form, {}).permit(:comment, reasons: [])
    end
  end
end
