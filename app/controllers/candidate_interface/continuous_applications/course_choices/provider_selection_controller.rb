module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ProviderSelectionController < BaseController
      private

        def step_params
          return provider_params if params[:provider_id].present?

          params
        end

        def provider_params
          ActionController::Parameters.new({
            current_step => { provider_id: params[:provider_id] },
          })
        end

        def current_step
          :provider_selection
        end
      end
    end
  end
end
