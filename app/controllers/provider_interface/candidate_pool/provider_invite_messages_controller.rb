module ProviderInterface
  module CandidatePool
    class ProviderInviteMessagesController < ProviderInterfaceController
      before_action :set_candidate
      before_action :set_back_path, only: %i[edit update]

      def new
        @pool_invite = PoolInviteMessageForm.new(invite:)
        @course = invite.course
      end

      def edit
        @pool_invite = PoolInviteMessageForm.new(
          {
            invite:,
            provider_message: invite.provider_message,
            message_content: invite.message_content,
          },
        )
        @course = invite.course
      end

      def create
        @pool_invite = PoolInviteMessageForm.new(invite_message_params.merge(invite:))

        if @pool_invite.valid?
          @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, invite)
        else
          @course = invite.course
          render :new
        end
      end

      def update
        @pool_invite = PoolInviteMessageForm.new(invite_message_params.merge(invite:))

        if @pool_invite.valid?
          @pool_invite.save
          redirect_to provider_interface_candidate_pool_candidate_draft_invite_path(@candidate, invite)
        else
          @course = invite.course
          render :edit
        end
      end

    private

      def set_candidate
        @candidate ||= Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id: params.expect(:candidate_id)).candidate
      end

      def set_back_path
        if return_to_review?
          @back_path = provider_interface_candidate_pool_candidate_draft_invite_path(
            @candidate,
            invite,
          )
        end
      end

      def return_to_review?
        params[:return_to] == 'review' ||
          params.dig(:provider_interface_pool_invite_message_form, :return_to) == 'review'
      end

      def invite
        @invite ||= current_provider_user.pool_invites.find_by(
          id: params.expect(:draft_invite_id),
          status: :draft,
        )
      end

      def invite_message_params
        params.expect(
          provider_interface_pool_invite_message_form: %i[provider_message message_content return_to],
        )
      end
    end
  end
end
