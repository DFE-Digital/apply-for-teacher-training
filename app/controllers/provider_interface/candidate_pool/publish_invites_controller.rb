module ProviderInterface
  module CandidatePool
    class PublishInvitesController < ProviderInterfaceController
      before_action :set_policy
      before_action :set_candidate
      before_action :redirect_if_invite_is_not_found

      def create
        if @policy.can_invite_candidates?

          @pool_invite = PoolInviteForm.build_from_invite(
            invite:,
            current_provider_user:,
          )

          if @pool_invite.valid?
            ActiveRecord::Base.transaction do
              invite.published!
              if FeatureFlag.inactive?(:grouped_invite_email)
                invite.sent_to_candidate!
                CandidateMailer.candidate_invites(invite.candidate, [invite]).deliver_later
              end
            end

            flash[:success] = t(
              '.success',
              candidate: invite.candidate.redacted_full_name_current_cycle,
              candidate_id: invite.candidate_id,
              course: invite.course.name_code_and_course_provider,
            )
            redirect_to tab_user_came_from
          else
            render '/provider_interface/candidate_pool/draft_invites/edit'
          end
        else
          redirect_to tab_user_came_from
        end
      end

    private

      def set_policy
        @policy = ProviderInterface::Policies::CandidatePoolInvitesPolicy.new(current_provider_user)
      end

      def set_candidate
        @candidate ||= Pool::Candidates.application_forms_for_provider
         .find_by(candidate_id: params.expect(:candidate_id))&.candidate

        redirect_to provider_interface_candidate_pool_root_path if @candidate.blank?
      end

      def invite
        @invite ||= Pool::Invite.find_by(
          id: params.expect(:draft_invite_id),
          provider_id: current_provider_user.provider_ids,
          status: :draft,
        )
      end

      def redirect_if_invite_is_not_found
        if invite.nil?
          redirect_to provider_interface_candidate_pool_candidate_path(@candidate)
        end
      end

      def tab_user_came_from
        last_filter = current_provider_user.last_find_candidate_filter

        return provider_interface_candidate_pool_root_path if last_filter.nil?
        page = last_filter.pagination_page || 1

        if last_filter.find_candidates_not_seen?
          provider_interface_candidate_pool_not_seen_index_path(page:)
        elsif last_filter.find_candidates_invited?
          provider_interface_candidate_pool_invites_path(page:)
        else
          provider_interface_candidate_pool_root_path(page:)
        end
      end
    end
  end
end
