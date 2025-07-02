module ProviderInterface
  module CandidatePool
    class NotSeenController < ProviderInterfaceController
      include Pagy::Backend

      def index
        @filter = ProviderInterface::NotSeenCandidatesFilter.new(
          filter_params:,
          current_provider_user:,
          remove_filters:,
        )
        @filter.save

        @pagy, @application_forms = pagy(
          Pool::Candidates.new(filters: @filter.applied_filters).application_forms_not_seen_by_provider_user(
            current_provider_user,
          ),
        )
      end

    private

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
