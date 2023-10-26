module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class CourseSiteController < BaseController
        before_action :redirect_duplicate, only: %w[new] # rubocop:disable Rails/LexicallyScopedActionFilter

      private

        def current_step
          :course_site
        end

        def redirect_duplicate
          return unless current_application.contains_course?(Course.find(params[:course_id]))

          redirect_to candidate_interface_continuous_applications_duplicate_course_selection_path(params[:provider_id], params[:course_id])
        end
      end
    end
  end
end
