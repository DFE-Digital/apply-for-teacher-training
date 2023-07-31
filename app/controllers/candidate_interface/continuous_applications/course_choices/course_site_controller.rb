module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseSiteController < BaseController
      private

        def step_params
          return provider_params if params[current_step].blank?

          params[current_step][:provider_id] = params[:provider_id]
          params[current_step][:course_id] = params[:course_id]
          params[current_step][:study_mode] = params[:study_mode]
          params
        end

        def provider_params
          ActionController::Parameters.new(
            { current_step => { provider_id: params[:provider_id], course_id: params[:course_id], study_mode: params[:study_mode] } },
          )
        end

        def current_step
          :course_site
        end
      end
    end
  end
end
