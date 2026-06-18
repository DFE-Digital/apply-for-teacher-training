module CandidateInterface
  class GcseInternationalStructuredGradesForm
    include ActiveModel::Model

    attr_accessor :grade, :non_structured_grade, :structured_grades

    validates :grade, presence: true
    validates :non_structured_grade, presence: true, if: :non_structured?

    def self.build_from_qualification(application_qualification, structured_grades: [])
      grade = application_qualification.grade
      structured = grade.present? && grade.in?(structured_grades)

      new(
        grade: if structured
                 grade
               else
                 (grade.present? ? 'other' : nil)
               end,
        non_structured_grade: structured ? nil : grade,
      )
    end

    def save(application_qualification)
      return false unless valid?

      application_qualification.update!(
        grade: non_structured? ? non_structured_grade : grade,
      )
    end

    def non_structured?
      grade == 'other'
    end
  end
end
