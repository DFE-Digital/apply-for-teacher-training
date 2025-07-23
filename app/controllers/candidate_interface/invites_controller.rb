module CandidateInterface
  class InvitesController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :redirect_if_feature_off_and_no_submitted_application

    def index
      @invites = current_application.published_invites.includes(:application_choice).order(sent_to_candidate_at: :desc)
    end

    def show
      @invite = Pool::Invite.find(params[:id])
      @fac_invite_response_form = CandidateInterface::FacInviteResponseForm.new(
        application_form: current_application,
        invite: @invite,
      )
    end

    def update
      @invite = Pool::Invite.find(params[:id])
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
          redirect_to_candidate_root
        end
      else
        track_validation_error(@fac_invite_response_form)
        render :show
      end
    end

    def redirect_if_feature_off_and_no_submitted_application
      unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
        redirect_to root_path
      end
    end

  private

    def fac_invite_response_form_params
      params.fetch(:candidate_interface_fac_invite_response_form, {}).permit(:apply_for_this_course)
    end
  end
end
