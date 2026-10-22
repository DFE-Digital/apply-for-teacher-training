module SupportInterface
  class CourseController < SupportInterfaceController
    def show
      authorize nil, :show?, policy_class: SupportInterface::ProviderPolicy

      @course = Course.find(params.expect(:course_id))
    end

    def applications
      authorize nil, :show?, policy_class: SupportInterface::CandidatePolicy

      @course = Course.find(params.expect(:course_id))
    end

    def vacancies
      authorize nil, :show?, policy_class: SupportInterface::ProviderPolicy

      @course = Course.find(params.expect(:course_id))
      @course_options = CourseOption.where(course: @course).includes(:site, :course)
    end
  end
end
