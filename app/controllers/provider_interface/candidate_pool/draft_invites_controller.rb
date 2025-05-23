module ProviderInterface
  module CandidatePool
    class DraftInvitesController < ProviderInterfaceController
      before_action :set_policy
      before_action :redirect_if_candidate_cannot_send_invites
      before_action :set_candidate

      def show
        if @policy.can_view_invite?(invite)

          @pool_invite = PoolInviteForm.build_from_invite(
            invite:,
            current_provider_user:,
          )
        else
          redirect_to provider_interface_candidate_pool_candidates_path
        end
      end

      def new
        @pool_invite = PoolInviteForm.new(current_provider_user:)
      end

      def edit
        if @policy.can_edit_invite?(invite)
          @pool_invite = PoolInviteForm.build_from_invite(
            invite:,
            current_provider_user:,
          )
        else
          redirect_to provider_interface_candidate_pool_candidates_path
        end
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
        @candidate ||= Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id: params.expect(:candidate_id)).candidate
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

      def set_policy
        @policy = ProviderInterface::Policies::CandidatePoolInvitesPolicy.new(current_provider_user)
      end

      def redirect_if_candidate_cannot_send_invites
        unless @policy.can_invite_candidates?
          redirect_to provider_interface_candidate_pool_candidates_path
        end
      end
    end
  end
end
