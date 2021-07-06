module SupportInterface
  module ApplicationForms
    module ApplicationChoices
      class ChangeOfferedCourseController < BaseController
        before_action :build_application_form, :build_application_choice, :redirect_to_application_form_unless_accepted_and_change_offered_course_course_flag_active

        def change_offered_course_search
          @course_search = CourseSearchForm.new
        end

        def search
          @course_search = CourseSearchForm.new(
            application_form_id: @application_form.id,
            course_code: course_search_params[:course_code],
          )

          if @course_search.valid?
            redirect_to support_interface_application_form_application_choice_choose_offered_course_option_path(
              course_code: course_search_params[:course_code],
              application_form_id: @application_form.id,
              application_choice_id: @application_choice.id,
            )
          else
            render :change_offered_course_search
          end
        end

        def offered_course_options
          @pick_course = PickCourseForm.new(
            course_code: params[:course_code],
            application_form_id: @application_form.id,
          )
        end

        def choose_offered_course_option
          @pick_course = PickCourseForm.new(
            application_form_id: @application_form.id,
            course_code: params[:course_code],
            course_option_id: course_option_id,
          )

          if @pick_course.valid?(:save)
            redirect_to support_interface_application_form_application_choice_confirm_offered_course_option_path(
              application_form_id: @application_form.id,
              application_choice_id: @application_choice.id,
              course_option_id: course_option_id,
            )
          else
            render :offered_course_options
          end
        end

        def confirm_offered_course_option
          @update_offered_course_option_form = UpdateOfferedCourseOptionForm.new(course_option_id: params[:course_option_id])
        end

        def update_offered_course_option
          @update_offered_course_option_form = UpdateOfferedCourseOptionForm.new(confirm_offered_course_option_params)

          if @update_offered_course_option_form.save(@application_choice)
            flash[:success] = 'Offered course choice updated successfully'
            redirect_to support_interface_application_form_path(@application_form.id)
          else
            render :confirm_offered_course_option
          end
        end

      private

        def course_search_params
          params.require(:support_interface_application_forms_course_search_form)
                .permit(:course_code)
        end

        def course_option_id
          params.dig(:support_interface_application_forms_pick_course_form, :course_option_id)
        end

        def confirm_offered_course_option_params
          params.require(:support_interface_application_forms_update_offered_course_option_form).permit(:course_option_id, :audit_comment, :accept_guidance)
        end

        def redirect_to_application_form_unless_accepted_and_change_offered_course_course_flag_active
          return if FeatureFlag.active?(:support_user_change_offered_course) && application_choice_pending_recruitment?

          redirect_to support_interface_application_form_path(@application_form.id)
        end

        def application_choice_pending_recruitment?
          @application_choice.pending_conditions? || @application_choice.unconditional_offer_pending_recruitment?
        end
      end
    end
  end
end
