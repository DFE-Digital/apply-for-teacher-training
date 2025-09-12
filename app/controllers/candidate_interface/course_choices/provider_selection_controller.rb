module CandidateInterface
  module CourseChoices
    class ProviderSelectionController < CandidateInterface::CourseChoices::BaseController
    private

      def step_params
        params[:provider_id].present? ? provider_params : params
      end

      def provider_params
        ActionController::Parameters.new({
          current_step => {
            provider_id: params[:provider_id],
            course_id: params[:course_id],
          }.compact_blank,
        })
      end

      def current_step
        :provider_selection
      end
    end
  end
end
