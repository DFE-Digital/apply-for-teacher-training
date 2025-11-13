module CandidateInterface
  class CourseUnavailableController < CandidateInterfaceController
    before_action CarryOverFilter
    before_action :set_invite

    def show; end

  private

    def set_invite
      @invite = current_application.published_invites.find_by(id: params.expect(:invite_id))

      if @invite.nil?
        redirect_to root_path
      end
    end
  end
end
