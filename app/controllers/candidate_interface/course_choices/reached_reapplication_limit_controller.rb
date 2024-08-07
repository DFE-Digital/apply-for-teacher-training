module CandidateInterface
  module CourseChoices
    class ReachedReapplicationLimitController < CandidateInterface::CourseChoices::BaseController
      before_action :set_course
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
        :reached_reapplication_limit
      end

      def set_course
        @course = Course.find(params[:course_id])
      end
    end
  end
end
