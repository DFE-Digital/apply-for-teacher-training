module CandidateInterface
  class CourseUnavailableController < CandidateInterfaceController
    before_action CarryOverFilter
    before_action :set_invite

    def show; end

  private

    def set_invite
      @invite = Pool::Invite.find(params.expect(:invite_id))
    end
  end
end
