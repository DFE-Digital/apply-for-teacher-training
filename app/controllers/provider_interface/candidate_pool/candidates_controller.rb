module ProviderInterface
  module CandidatePool
    class CandidatesController < ProviderInterfaceController
      include Pagy::Backend

      before_action :set_policy
      before_action :set_back_link, only: [:show]

      def index
        @filter = ProviderInterface::CandidatePoolFilter.new(
          filter_params:,
          current_provider_user:,
          apply_filters: apply_filters.present?,
        )
        @filter.save

        @pagy, @application_forms = pagy(
          Pool::Candidates.application_forms_for_provider(
            filters: @filter.applied_filters,
            provider_user: current_provider_user,
            with_statuses: true,
          ),
          overflow: :last_page,
        )

        if @pagy.overflow?
          @filter.save_pagination(@pagy.last)
        else
          @filter.save_pagination(@pagy.page)
        end
      end

      def show
        @application_form = Pool::Candidates.application_forms_for_provider
          .find_by(candidate_id:)
        @candidate = @application_form&.candidate

        if @application_form.blank? || @candidate.blank?
          redirect_to provider_interface_candidate_pool_candidate_not_in_pool_path(candidate_id)
        else
          current_provider_user.pool_views.find_or_create_by(
            application_form_id: @application_form.id,
            recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
          )
        end
      end

    private

      def set_policy
        @policy = ProviderInterface::Policies::CandidatePoolInvitesPolicy.new(current_provider_user)
      end

      def apply_filters
        params.permit(:apply_filters)
      end

      def candidate_id
        params.expect(:id)
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

      def set_back_link
        @back_link ||= if params[:return_to] == 'not_seen'
                         page = current_provider_user.find_a_candidate_not_seen_filter&.pagination_page
                         provider_interface_candidate_pool_not_seen_index_path(page:)
                       elsif params[:return_to] == 'invited'
                         page = current_provider_user.find_candidates_invited_filter&.pagination_page
                         provider_interface_candidate_pool_invites_path(page:)
                       elsif params[:return_to] == 'all'
                         page = current_provider_user.find_a_candidate_all_filter&.pagination_page
                         provider_interface_candidate_pool_root_path(page:)
                       else
                         provider_interface_candidate_pool_root_path
                       end
      end
    end
  end
end
