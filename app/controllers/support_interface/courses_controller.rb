module SupportInterface
  class CoursesController < SupportInterfaceController
    def show
      @course = Course.find(params[:course_id])
    end

    def update
      @course = Course.find(params[:course_id])

      if @course.update(params.require(:course).permit(:open_on_apply))
        flash[:success] = 'Successfully updated course'
        redirect_to support_interface_course_path(@course)
      else
        render :show
      end
    end
  end
end
