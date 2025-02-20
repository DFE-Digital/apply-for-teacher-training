module ProviderInterface
  class CandidatePoolInvitesController < ProviderInterfaceController
    before_action :set_candidate, only: %i[new edit create]

    def show
      @pool_invite = PoolInviteForm.build_from_invite(
        invite:,
        current_provider_user:,
      )
    end

    def new
      @pool_invite = PoolInviteForm.new(current_provider_user:)
    end

    def edit
      @pool_invite = PoolInviteForm.build_from_invite(
        invite:,
        current_provider_user:,
      )
    end

    def create
      @pool_invite = PoolInviteForm.new(
        current_provider_user:,
        candidate: @candidate,
        attributes:,
      )

      if @pool_invite.valid?
        record = @pool_invite.persist!
        redirect_to provider_interface_show_candidate_pool_invite_path(record)
      else
        render invite.present? ? :edit : :new
      end
    end

    def publish
      @pool_invite = PoolInviteForm.build_from_invite(
        invite:,
        current_provider_user:,
      )

      if @pool_invite.valid?
        invite.published!

        flash[:success] = t(
          '.success',
          candidate: invite.candidate.redacted_full_name_current_cycle,
          course: invite.course.name_code_and_course_provider,
        )
        redirect_to provider_interface_find_candidates_path
      else
        @candidate = invite.candidate
        render :edit
      end
    end

  private

    def set_candidate
      @candidate ||= Pool::Candidates.for_provider(
        providers: current_provider_user.providers,
      ).find_by(id: params.expect(:candidate_id))
    end

    def attributes
      params.expect(
        provider_interface_pool_invite_form: %i[course_id id status],
      )
    end

    def invite
      @invite ||= Pool::Invite.find_by(
        id: params[:id],
        provider_id: current_provider_user.provider_ids,
      )
    end
  end
end
