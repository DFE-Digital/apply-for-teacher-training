module SupportInterface
  class ChangeCourseController < SupportInterfaceController
    def options
      @pick_option_form = SupportInterface::ChangeCourseForm.new(application_form: application_form)
    end

    def pick_option
      change_course_form = SupportInterface::ChangeCourseForm.new(params.require(:support_interface_change_course_form).permit(:change_type))

      case change_course_form.change_type
      when 'add_course'
        redirect_to support_interface_add_course_to_application_path(application_form)
      else
        flash[:info] = "Sorry - we haven't built this feature yet"
        redirect_to support_interface_change_course_path(application_form)
      end
    end

    def select_course_to_add
      @form = SupportInterface::AddCourseToApplicationForm.new(application_form: application_form)
    end

    def add_course
      course_option_id = params.require(:support_interface_add_course_to_application_form).fetch(:course_option_id)

      @form = SupportInterface::AddCourseToApplicationForm.new(
        application_form: application_form,
        course_option_id: course_option_id,
      )

      if @form.save
        redirect_to support_interface_application_form_path(application_form)
      else
        render :select_course_to_add
      end
    end

  private

    def application_form
      @_application_form ||= ApplicationForm.find(params[:application_form_id])
    end
  end
end
