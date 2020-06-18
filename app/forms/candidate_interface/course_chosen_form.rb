module CandidateInterface
  class CourseChosenForm
    include ActiveModel::Model

    attr_accessor :choice

    validates :choice, presence: true

    def chosen_a_course?
      choice == 'yes'
    end
  end
end
