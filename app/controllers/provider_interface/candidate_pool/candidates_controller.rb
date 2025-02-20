module ProviderInterface
  module CandidatePool
    class CandidatesController < ProviderInterfaceController
      include Pagy::Backend
      before_action :redirect_to_applications_unless_provider_opted_in
      before_action :set_candidate, only: :show

      def index
        @pagy, @candidates = pagy(
          Pool::Candidates.for_provider(providers: current_provider_user.providers)
            .order('application_forms.submitted_at'),
        )
      end

      def show
        @application_form = @candidate.application_forms.current_cycle.last
      end

    private

      def set_candidate
        @candidate ||= Pool::Candidates.for_provider(
          providers: current_provider_user.providers,
        ).find_by(id: params.expect(:id))
      end

      def redirect_to_applications_unless_provider_opted_in
        invites = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

        redirect_to provider_interface_applications_path if invites.blank?
      end
    end
  end
end
