module ProviderInterface
  module CandidatePool
    class DraftInvitesController < ProviderInterfaceController
      before_action :set_candidate

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
          pool_invite_form_params:,
        )

        if @pool_invite.valid?
          invite = @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, invite)
        else
          render :new
        end
      end

      def update
        byebug
        @pool_invite = PoolInviteForm.new(
          current_provider_user:,
          candidate: @candidate,
          pool_invite_form_params:,
        )

        if @pool_invite.valid? && @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate)
        else
          render :edit
        end
      end

    private

      def set_candidate
        @candidate ||= Pool::Candidates.application_forms_for_provider(
          providers: current_provider_user.providers,
        ).find_by(candidate_id: params.expect(:candidate_id)).candidate
      end

      def pool_invite_form_params
        params.expect(
          provider_interface_pool_invite_form: %i[course_id id status],
        )
      end

      def invite
        @invite ||= Pool::Invite.find_by(
          id: params.expect(:id),
          provider_id: current_provider_user.provider_ids,
          status: :draft,
        )
      end
    end
  end
end
