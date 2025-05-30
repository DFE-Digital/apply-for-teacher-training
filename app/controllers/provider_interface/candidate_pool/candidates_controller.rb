module ProviderInterface
  module CandidatePool
    class CandidatesController < ProviderInterfaceController
      include Pagy::Backend
      before_action :redirect_to_applications_unless_provider_opted_in
      before_action :set_policy

      def index
        @filter = ProviderInterface::CandidatePoolFilter.new(
          filter_params:,
          current_provider_user:,
          remove_filters:,
        )
        @filter.save

        @pagy, @application_forms = pagy(
          Pool::Candidates.application_forms_for_provider(
            filters: @filter.applied_filters,
          ),
        )
      end

      def show
        @application_form = Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id: params.expect(:id))

        @candidate = @application_form.candidate
      end

    private

      def set_policy
        @policy = ProviderInterface::Policies::CandidatePoolInvitesPolicy.new(current_provider_user)
      end

      def redirect_to_applications_unless_provider_opted_in
        invites = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

        redirect_to provider_interface_applications_path if invites.blank?
      end

      def remove_filters
        params.permit(:remove_filters)
      end

      def filter_params
        params.permit(
          :location,
          subject_ids: [],
          study_mode: [],
          course_type: [],
          visa_sponsorship: [],
        )
      end
    end
  end
end
