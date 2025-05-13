module ProviderInterface
  module CandidatePool
    class PublishInvitesController < ProviderInterfaceController
      before_action :set_policy
      before_action :set_candidate

      def create
        if @policy.can_invite_candidates?

          @pool_invite = PoolInviteForm.build_from_invite(
            invite:,
            current_provider_user:,
          )

          if @pool_invite.valid?
            invite.published!

            flash[:success] = t(
              '.success',
              candidate: invite.candidate.redacted_full_name_current_cycle,
              candidate_id: invite.candidate_id,
              course: invite.course.name_code_and_course_provider,
            )
            redirect_to provider_interface_candidate_pool_root_path

            CandidateMailer.course_invite(invite).deliver_later
          else
            render '/provider_interface/candidate_pool/draft_invites/edit'
          end
        else
          redirect_to provider_interface_candidate_pool_candidates_path
        end
      end

    private

      def set_policy
        @policy = ProviderInterface::Policies::CandidatePoolInvitesPolicy.new(current_provider_user)
      end

      def set_candidate
        @candidate ||= Pool::Candidates.application_forms_for_provider(
          providers: current_provider_user.providers,
        ).find_by(candidate_id: params.expect(:candidate_id)).candidate
      end

      def invite
        @invite ||= Pool::Invite.find_by(
          id: params.expect(:draft_invite_id),
          provider_id: current_provider_user.provider_ids,
          status: :draft,
        )
      end
    end
  end
end
