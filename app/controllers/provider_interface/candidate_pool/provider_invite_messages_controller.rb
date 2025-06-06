module ProviderInterface
  module CandidatePool
    class ProviderInviteMessagesController < ProviderInterfaceController
      before_action :set_candidate
      before_action :set_back_path, only: %i[edit]

      def new
        @pool_invite = PoolInviteMessageForm.new(invite:)
        @course = invite.course
      end

      def edit
        @pool_invite = PoolInviteMessageForm.new(
          invite:,
          invite_message_params: {
            provider_message: invite.provider_message,
            message_content: invite.message_content,
          },
        )
        @course = invite.course
      end

      def create
        @pool_invite = PoolInviteMessageForm.new(
          invite:,
          invite_message_params:,
        )

        if @pool_invite.valid?
          @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, invite)
        else
          @course = invite.course
          render :new
        end
      end

      def update
        @pool_invite = PoolInviteMessageForm.new(
          invite:,
          invite_message_params:,
        )

        if @pool_invite.valid?
          @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, invite)
        else
          @course = invite.course
          render :new
        end
      end

    private

      def set_candidate
        @candidate ||= Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id: params.expect(:candidate_id)).candidate
      end

      def set_back_path
        if params[:return_to] == 'review'
          @back_path = provider_interface_candidate_pool_candidate_draft_invite_path(
            @candidate,
            invite,
          )
        end
      end

      def invite
        @invite ||= Pool::Invite.find_by(
          id: params.expect(:draft_invite_id),
          provider_id: current_provider_user.provider_ids,
          status: :draft,
        )
      end

      def invite_message_params
        params.expect(
          provider_interface_pool_invite_message_form: %i[provider_message message_content],
        )
      end
    end
  end
end
