module ProviderInterface
  module CandidatePool
    class NotSeenController < ProviderInterfaceController
      include Pagy::Backend

      def index
        @filter = ProviderInterface::NotSeenCandidatesFilter.new(
          filter_params:,
          current_provider_user:,
          apply_filters: apply_filters.present?,
        )
        @filter.save

        @pagy, @application_forms = pagy(
          Pool::Candidates.new(filters: @filter.applied_filters).application_forms_not_seen_by_provider_user(
            current_provider_user,
          ),
          overflow: :last_page,
        )

        if @pagy.overflow?
          @filter.save_pagination(@pagy.last)
        else
          @filter.save_pagination(@pagy.page)
        end
      end

    private

      def apply_filters
        params.permit(:apply_filters)
      end

      def filter_params
        params.permit(
          :location,
          :candidate_id,
          :candidate_search,
          subject_ids: [],
          study_mode: [],
          course_type: [],
          visa_sponsorship: [],
          funding_type: [],
        )
      end
    end
  end
end
