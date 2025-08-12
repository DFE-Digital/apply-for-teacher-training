module CandidateInterface
  class InvitesController < CandidateInterfaceController
    before_action CarryOverFilter
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action :redirect_if_feature_off_and_no_submitted_application
    before_action :set_invite, only: %i[edit update]

    def index
      @not_responded_invites = current_application.published_invites.not_responded_course_open
        .order(sent_to_candidate_at: :desc)
      @invites = current_application.unactionable_invites
        .includes(:provider, :application_choice, course: :provider)
        .order(sent_to_candidate_at: :desc)
    end

    def edit
      if @invite.course_closed?
        redirect_to candidate_interface_invite_course_unavailable_path(@invite)
      end

      @fac_invite_response_form = CandidateInterface::FacInviteResponseForm.new(invite: @invite)
    end

    def update
      @fac_invite_response_form ||= CandidateInterface::FacInviteResponseForm.new(invite_response_form_params.merge(invite: @invite))
      if @fac_invite_response_form.save
        redirect_to @fac_invite_response_form.path_to_redirect
      else
        track_validation_error(@fac_invite_response_form)
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def set_invite
      @invite = Pool::Invite.find(params.expect(:id))
    end

    def invite_response_form_params
      params.fetch(:candidate_interface_fac_invite_response_form, {}).permit(:apply_for_this_course)
    end

    def redirect_if_feature_off_and_no_submitted_application
      unless FeatureFlag.active?(:candidate_preferences) && current_application.submitted_applications?
        redirect_to root_path
      end
    end
  end
end
