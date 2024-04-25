module SupportInterface
  class CourseController < SupportInterfaceController
    def show
      @course = Course.find(params[:course_id])
    end

    def applications
      @course = Course.find(params[:course_id])
    end

    def vacancies
      @course = Course.find(params[:course_id])
      @course_options = CourseOption.where(course: @course).includes(:site, :course)
    end
  end
end
