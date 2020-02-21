module CandidateInterface
  class CourseSelectionForm
    include ActiveModel::Model

    attr_accessor :confirm, :course

    def initialize(course)
      self.course = course
    end

    def course_and_provider_name
      "#{course.provider.name} #{course.name_and_code}"
    end
  end
end
