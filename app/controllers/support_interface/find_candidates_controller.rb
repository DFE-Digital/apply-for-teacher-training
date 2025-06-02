module SupportInterface
  class FindCandidatesController < SupportInterfaceController
    def index
      @filter = SupportInterface::CandidatePoolFilter.new(
        filter_params:,
      )

      @pagy, @application_forms = pagy(
        Pool::Candidates.application_forms_for_provider(
          filters: @filter.applied_filters,
        ),
      )
    end

  private

    def filter_params
      params.permit(
        :within,
        :original_location,
        :remove,
        subject_ids: [],
        study_mode: [],
        course_type: [],
        visa_sponsorship: [],
      )
    end
  end
end
