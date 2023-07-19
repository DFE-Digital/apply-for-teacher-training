module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ProviderSelectionController < BaseController
      private

        def step_params
          params
        end

        def current_step
          :provider_selection
        end
      end
    end
  end
end
