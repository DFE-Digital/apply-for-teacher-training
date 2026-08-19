module CandidateInterface
  module CourseChoices
    class ProviderSelectionController < CandidateInterface::CourseChoices::BaseController
    private

      def current_step
        :provider_selection
      end

      def wizard_controller?
        true
      end
    end
  end
end
