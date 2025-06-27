module ProviderInterface
  module CandidatePool
    class InvitesController < ProviderInterfaceController
      include Pagy::Backend
      before_action :redirect_to_applications_unless_provider_opted_in

      def index
        @filter = CandidateInvitesFilter.new(filter_params:, provider_user: current_provider_user)

        @pagy, @candidate_invites = pagy(@filter.applied_filters)
      end

    private

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
