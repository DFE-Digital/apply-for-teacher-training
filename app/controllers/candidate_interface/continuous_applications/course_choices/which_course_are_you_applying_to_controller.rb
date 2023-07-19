module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class WhichCourseAreYouApplyingToController < BaseController
      private

        def step_params
          return provider_params if params[current_step].blank?

          params[current_step][:provider_id] = params[:provider_id]
          params
        end

        def provider_params
          { current_step => { provider_id: params[:provider_id] } }
        end

        def current_step
          :which_course_are_you_applying_to
        end
      end
    end
  end
end
