module SupportInterface
  class AddCourseController < SupportInterfaceController
    def new
      @pick_course = SupportInterface::AddCourseForm.new(application_form_id: params[:application_form_id])
    end

    def create
      @pick_course = SupportInterface::AddCourseForm.new(course_params)

      if @pick_course.save
        redirect_to support_interface_application_form_path
      else
        render :new
      end
    end

  private

    def course_params
      params.require(:support_interface_add_course_form)
            .permit(:application_form_id, :course_option_id)
    end
  end
end
