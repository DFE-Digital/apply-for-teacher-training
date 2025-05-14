module ProviderInterface
  module CandidatePool
    class CandidatesController < ProviderInterfaceController
      include Pagy::Backend
      before_action :redirect_to_applications_unless_provider_opted_in

      def index
        @filter = ProviderInterface::CandidatePoolFilter.new(
          filter_params:,
          current_provider_user:,
        )
        @filter_form = ProviderInterface::CandidatePoolFilterForm.new(
          form_filter_params[:provider_interface_candidate_pool_filter_form],
        )
        @filter_form.valid?

        puts "FILTERS"
        puts "FILTERS"
        puts "FILTERS"
        puts "FILTERS"
        puts @filter_form.applied_filters
        @pagy, @application_forms = pagy(
          Pool::Candidates.application_forms_for_provider(
            providers: current_provider_user.providers,
            filters: @filter_form.applied_filters,
          ),
        )
      end

      def show
        @application_form = Pool::Candidates.application_forms_for_provider(
          providers: current_provider_user.providers,
        )
        .find_by(candidate_id: params.expect(:id))

        @candidate = @application_form.candidate
      end

    private

      def redirect_to_applications_unless_provider_opted_in
        invites = CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids)

        redirect_to provider_interface_applications_path if invites.blank?
      end

      def form_filter_params
        params.permit(
          provider_interface_candidate_pool_filter_form: [
            :location,
            course_ids: [],
            study_types: [],
            course_types: [],
            visa_sponsorships: [],
          ],
        )
      end

      def filter_params
        params.permit(
          :within,
          :original_location,
          :remove,
          subject: [],
          study_mode: [],
          course_type: [],
          visa_sponsorship: [],
        )
      end
    end
  end
end
