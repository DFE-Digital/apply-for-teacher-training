module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseStudyModeController < BaseController
      private

        def step_params
          return provider_params if params[current_step].blank?

          params[current_step][:provider_id] = params[:provider_id]
          params[current_step][:course_id] = params[:course_id]
          params
        end

        def provider_params
          { current_step => { provider_id: params[:provider_id], course_id: params[:provider_id] } }
        end

        def current_step
          :course_study_mode
        end
      end
    end
  end
end
