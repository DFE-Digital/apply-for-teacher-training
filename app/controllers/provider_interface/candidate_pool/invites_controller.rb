module ProviderInterface
  module CandidatePool
    class InvitesController < ProviderInterfaceController
      include Pagy::Backend
      before_action :redirect_to_applications_unless_provider_opted_in
      before_action :set_invite, only: :show
      before_action :redirect_if_candidate_in_pool, only: :show

      def index
        @filter = CandidateInvitesFilter.new(filter_params:, provider_user: current_provider_user)

        @pagy, @candidate_invites = pagy(@filter.applied_filters)
      end

      def show; end

    private

      def set_invite
        @invite = Pool::Invite
                    .published
                    .current_cycle
                    .published
                    .where(provider: current_provider_user.providers)
                    .find(params[:id])

        redirect_to provider_interface_candidate_pool_invites_path if @invite.nil?
      end

      def redirect_if_candidate_in_pool
        pool_candidate = Pool::Candidates.application_forms_for_provider.find_by(candidate_id: @invite.candidate_id)

        redirect_to provider_interface_candidate_pool_candidate_path(@invite.candidate_id) if pool_candidate.present?
      end

      def redirect_to_applications_unless_provider_opted_in
        opt_in = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

        redirect_to provider_interface_applications_path if opt_in.blank?
      end

      def filter_params
        params.permit(:remove, status: [], courses: [])
      end
    end
  end
end
