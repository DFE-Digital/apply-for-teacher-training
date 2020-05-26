module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def ucas_no_courses
      @provider = Provider.find_by!(id: params[:provider_id])
    end

    def ucas_with_course
      @provider = Provider.find_by!(id: params[:provider_id])
      @course = Course.find_by!(id: params[:course_id])
    end

    def full
      @course = Course.find(params[:course_id])
    end
  end
end
