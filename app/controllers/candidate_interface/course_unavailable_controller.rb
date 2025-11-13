module CandidateInterface
  class CourseUnavailableController < CandidateInterfaceController
    before_action CarryOverFilter
    before_action :set_invite
    before_action :redirect_if_invite_responded

    def show; end

  private

    def set_invite
      @invite = current_application.published_invites.find_by(id: params.expect(:invite_id))

      if @invite.nil?
        redirect_to root_path
      end
    end

    def redirect_if_invite_responded
      unless @invite.not_responded?
        redirect_to candidate_interface_invites_path
      end
    end
  end
end
