module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseStudyModeController < BaseController
        before_action :redirect_duplicate, only: %w[new] # rubocop:disable Rails/LexicallyScopedActionFilter

      private

        def step_params
          return provider_params if params[current_step].blank?

          params[current_step][:provider_id] = params[:provider_id]
          params[current_step][:course_id] = params[:course_id]
          params
        end

        def provider_params
          ActionController::Parameters.new(
            { current_step => { provider_id: params[:provider_id], course_id: params[:provider_id] } },
          )
        end

        def current_step
          :course_study_mode
        end

        def redirect_duplicate
          return unless current_application.contains_course?(Course.find(params[:course_id]))

          redirect_to candidate_interface_continuous_applications_duplicate_course_selection_path(params[:provider_id], params[:course_id])
        end
      end
    end
  end
end
