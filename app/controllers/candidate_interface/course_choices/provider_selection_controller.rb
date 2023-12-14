module CandidateInterface
  module CourseChoices
    class ProviderSelectionController < BaseController
      before_action { redirect_to_continuous_applications(action_name) if current_application.continuous_applications? }

      def new
        @pick_provider = PickProviderForm.new
        @provider_cache_key = "provider-list-#{Provider.maximum(:updated_at)}"
      end

      def create
        @pick_provider = PickProviderForm.new(
          provider_id: params.dig(:candidate_interface_pick_provider_form, :provider_id),
        )
        render :new and return unless @pick_provider.valid?

        redirect_to candidate_interface_edit_course_choices_course_path(@pick_provider.provider_id)
      end

    private

      def redirect_to_continuous_applications(action)
        case action
        when /new/
          redirect_to candidate_interface_continuous_applications_provider_selection_path
        end
      end
    end
  end
end
