module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class UCASController < BaseController
        def no_courses
          @course_choice = current_application.application_choices.find(params[:id])
          @provider = Provider.find_by!(id: params[:provider_id])
        end

        def with_course
          @course_choice = current_application.application_choices.find(params[:id])
          @provider = Provider.find_by!(id: params[:provider_id])
          @course = Course.find_by!(id: params[:course_id])
          @choose_action = params['choose_action']
        end
      end
    end
  end
end
