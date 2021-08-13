module CandidateInterface
  module CourseChoices
    class ProviderSelectionController < BaseController
      def new
        @pick_provider = PickProviderForm.new
        @provider_cache_key = "provider-list-#{Provider.maximum(:updated_at)}"
      end

      def create
        @pick_provider = PickProviderForm.new(
          provider_id: params.dig(:candidate_interface_pick_provider_form, :provider_id),
        )
        render :new and return unless @pick_provider.valid?

        if @pick_provider.courses_available?
          redirect_to candidate_interface_course_choices_course_path(@pick_provider.provider_id)
        else
          redirect_to candidate_interface_course_choices_ucas_no_courses_path(@pick_provider.provider_id)
        end
      end
    end
  end
end
