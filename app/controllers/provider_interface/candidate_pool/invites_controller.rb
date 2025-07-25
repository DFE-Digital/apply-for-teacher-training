module ProviderInterface
  module CandidatePool
    class InvitesController < ProviderInterfaceController
      include Pagy::Backend

      before_action :redirect_to_applications_unless_provider_opted_in
      before_action :set_invite, only: :show
      before_action :redirect_if_candidate_in_pool, only: :show
      before_action :set_back_link, only: :show

      def index
        @filter = CandidateInvitesFilter.new(filter_params:, provider_user: current_provider_user)

        @pagy, @candidate_invites = pagy(@filter.applied_filters, overflow: :last_page)

        if @pagy.overflow?
          @filter.save_pagination(@pagy.last)
        else
          @filter.save_pagination(@pagy.page)
        end
      end

      def show; end

    private

      def set_invite
        @invite = Pool::Invite
                    .published
                    .current_cycle
                    .where(provider: current_provider_user.providers)
                    .find_by(id: params[:id])

        redirect_to provider_interface_candidate_pool_invites_path if @invite.nil?
      end

      def set_back_link
        page = current_provider_user.find_candidates_invited_filter&.pagination_page || 1
        @back_link = provider_interface_candidate_pool_invites_path(page:)
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
