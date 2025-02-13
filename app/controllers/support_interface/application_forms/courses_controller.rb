module SupportInterface
  module ApplicationForms
    class CoursesController < SupportInterfaceController
      def new_search
        @course_search = CourseSearchForm.new(
          application_form_id:,
          course_code:,
        )
      end

      def search
        @course_search = CourseSearchForm.new(
          application_form_id:,
          course_code: course_search_params[:course_code],
        )

        if @course_search.valid?
          redirect_to support_interface_application_form_new_course_path(
            course_code: course_search_params[:course_code],
            application_form_id:,
          )
        else
          render :new_search
        end
      end

      def edit
        @change_course_choice = ChangeCourseChoiceForm.new
      end

      def update
        @change_course_choice = ChangeCourseChoiceForm.new(change_course_choice_params)

        begin
          if @change_course_choice.save(application_choice_id)
            flash[:success] = 'Course successfully changed'
            redirect_to support_interface_application_form_path(application_form_id)
          else
            @show_course_change_confirmation = checkbox_rendered?
            render :edit
          end
        rescue CourseChoiceError => e
          flash[:warning] = e.message
          render :edit
        rescue ApplicationStateError, CourseFullError, ProviderInterviewError => e
          flash[:warning] = e.message
          @show_course_change_confirmation = true
          @course_change_condition = course_change_condition(e)
          render :edit
        end
      end

    private

      def course_option_id
        params.dig(:support_interface_application_forms_pick_course_form, :course_option_id)
      end

      def checkbox_rendered?
        params.dig(:support_interface_application_forms_change_course_choice_form, :checkbox_rendered)
      end

      def course_search_params
        params
              .expect(support_interface_application_forms_course_search_form: [:course_code])
      end

      def change_course_choice_params
        params
              .expect(support_interface_application_forms_change_course_choice_form: %i[application_choice_id provider_code course_code study_mode site_code recruitment_cycle_year audit_comment_ticket accept_guidance confirm_course_change checkbox_rendered])
      end

      def application_form_id
        params[:application_form_id]
      end

      def application_choice_id
        params[:application_choice_id]
      end

      def course_code
        params[:course_code]
      end

      def course_change_condition(error)
        return 'with no vacancies' if error.is_a?(CourseFullError)
        return 'when interviews are pending' if error.is_a?(ProviderInterviewError)

        'when a decision has already been made on the application' if error.is_a?(ApplicationStateError)
      end
    end
  end
end
