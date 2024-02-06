module CandidateInterface
  module ContinuousApplications
    module CourseChoices
      class ReviewController < BaseController
        def show
          @show_delete_application = !courses_path_request?

          @application_choice = current_application.application_choices.find(params[:application_choice_id])
        end

      private

        def courses_path_request?
          request.referer&.match?('courses')
        end
      end
    end
  end
end
