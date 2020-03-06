module CandidateInterface
  class AddAnotherCourseForm
    include ActiveModel::Model

    attr_accessor :add_another_course
    validates :add_another_course, presence: true

    def add_another_course?
      add_another_course == 'yes'
    end
  end
end
