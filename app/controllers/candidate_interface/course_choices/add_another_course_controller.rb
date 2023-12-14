module CandidateInterface
  module CourseChoices
    class AddAnotherCourseController < BaseController
      def decide
        @add_another_course = AddAnotherCourseForm.new(add_another_course_params)
        return render :ask unless @add_another_course.valid?

        if @add_another_course.add_another_course?
          redirect_to candidate_interface_course_choices_choose_path
        else
          redirect_to candidate_interface_course_choices_review_path
        end
      end

    private

      def add_another_course_params
        params.fetch(:candidate_interface_add_another_course_form, {}).permit(:add_another_course)
      end
    end
  end
end
