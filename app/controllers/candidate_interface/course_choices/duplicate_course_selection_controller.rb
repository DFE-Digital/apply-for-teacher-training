module CandidateInterface
  module CourseChoices
    class DuplicateCourseSelectionController < CandidateInterface::CourseChoices::BaseController
      before_action :set_course
      before_action :set_backlink, only: [:new] # rubocop:disable Rails/LexicallyScopedActionFilter
      skip_before_action :redirect_to_your_applications_if_maximum_amount_of_choices_have_been_used

    private

      def step_params
        params[current_step] = {
          provider_id: params.delete(:provider_id),
          course_id: params.delete(:course_id),
        }
        params
      end

      def current_step
        :duplicate_course_selection
      end

      def set_course
        @course = Course.find(params[:course_id])
      end

      def set_backlink
        @backlink = candidate_interface_application_choices_path if request.referer.blank?
      end
    end
  end
end
