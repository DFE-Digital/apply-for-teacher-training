module CandidateInterface
  class CourseSelectionForm
    include ActiveModel::Model

    attr_accessor :confirm, :course

    def initialize(course, confirm = nil)
      self.course = course
      self.confirm = ActiveModel::Type::Boolean.new.cast(confirm)
    end

    def course_and_provider_name
      "#{course.provider.name} #{course.name_and_code}"
    end
  end
end
