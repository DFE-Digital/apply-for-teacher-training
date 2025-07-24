module CandidateInterface
  class InvitesController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :redirect_if_feature_off_and_no_submitted_application
    before_action :set_invite, only: %i[show decline update update_reason course_unavailable]

    def index
      @invites = current_application.published_invites.includes(:application_choice).order(sent_to_candidate_at: :desc)
    end

    def show
      if !@invite.course.open? || @invite.course.not_available?
        redirect_to course_unavailable_candidate_interface_invite_path(@invite)
        return
      end

      @fac_invite_response_form = CandidateInterface::FacInviteResponseForm.new(
        application_form: current_application,
        invite: @invite,
      )
    end

    def update
      @fac_invite_response_form ||= CandidateInterface::FacInviteResponseForm.new(fac_invite_response_form_params.merge(
                                                                                    application_form: current_application,
                                                                                    invite: @invite,
                                                                                  ))
      if @fac_invite_response_form.valid?
        if @fac_invite_response_form.accepted_invite?
          @fac_invite_response_form.save
          application_choice = @fac_invite_response_form.application_choice
          redirect_to candidate_interface_course_choices_course_review_path(application_choice.id)
        else
          redirect_to decline_candidate_interface_invite_path
        end
      else
        track_validation_error(@fac_invite_response_form)
        render :show
      end
    end

    def decline
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new
    end

    def update_reason
      @fac_invite_decline_reason_form = CandidateInterface::FacInviteDeclineReasonsForm.new(fac_invite_decline_reason_form_params)

      if @fac_invite_decline_reason_form.save(@invite)
        flash[:success] = [t('.header', course: @invite.course.name_and_code,
                                        provider: @invite.provider_name),
                           t('.body', link: view_context.govuk_link_to('apply to this course', candidate_interface_course_choices_course_confirm_selection_path(@invite.course)))]

        redirect_to candidate_interface_invites_path
      else
        render :decline
      end
    end

    def redirect_if_feature_off_and_no_submitted_application
      unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
        redirect_to root_path
      end
    end

    def course_unavailable; end

  private

    def set_invite
      @invite = Pool::Invite.find(params[:id])
    end

    def fac_invite_response_form_params
      params.fetch(:candidate_interface_fac_invite_response_form, {}).permit(:apply_for_this_course)
    end

    def fac_invite_decline_reason_form_params
      params.fetch(:candidate_interface_fac_invite_decline_reasons_form, {}).permit(:comment, reasons: [])
    end
  end
end
