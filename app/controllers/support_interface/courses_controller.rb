module SupportInterface
  class CoursesController < SupportInterfaceController
    def show
      @course = Course.find(params[:course_id])
    end
  end
end
