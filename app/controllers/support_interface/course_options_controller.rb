module SupportInterface
  class CourseOptionsController < SupportInterfaceController
    def index
      @course_options = CourseOption.where('vacancy_status != ?', 'vacancies').includes(:course, :site)
    end
  end
end
