module SupportInterface
  module ApplicationForms
    class CoursesController < SupportInterfaceController
      def new_search
        @course_search = CourseSearchForm.new(
          application_form_id: application_form_id,
          course_code: course_code,
        )
      end

      def search
        @course_search = CourseSearchForm.new(
          application_form_id: application_form_id,
          course_code: course_search_params[:course_code],
        )

        if @course_search.valid?
          redirect_to support_interface_application_form_new_course_path(
            course_code: course_search_params[:course_code],
            application_form_id: application_form_id,
          )
        else
          render :new_search
        end
      end

      def new
        @pick_course = PickCourseForm.new(
          course_code: course_code,
          application_form_id: application_form_id,
        )
      end

      def create
        @pick_course = PickCourseForm.new(
          course_option_id: course_option_id,
          course_code: course_code,
          application_form_id: application_form_id,
        )

        if @pick_course.save
          redirect_to support_interface_application_form_path
        else
          render :new
        end
      end

    private

      def course_option_id
        params.dig(:support_interface_application_forms_pick_course_form, :course_option_id)
      end

      def course_search_params
        params.require(:support_interface_application_forms_course_search_form)
              .permit(:course_code)
      end

      def application_form_id
        params[:application_form_id]
      end

      def course_code
        params[:course_code]
      end
    end
  end
end
