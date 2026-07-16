module CandidateInterface
  class GcseInternationalStructuredGradesForm
    include ActiveModel::Model

    attr_accessor :grade, :non_structured_grade, :structured_grades, :percentage

    validates :grade, presence: true
    validates :grade, numericality: { only_integer: true }, if: :percentage?
    validates :grade, length: { maximum: 3 }, if: :percentage?

    validates :non_structured_grade, presence: true, if: :non_structured?
    validates :non_structured_grade, length: { maximum: 20 }, if: :non_structured?

    def self.build_from_qualification(application_qualification, structured_grades: [], percentage: false)
      grade = application_qualification.grade
      structured = grade.present? && grade.in?(structured_grades)

      new(
        grade: if percentage
                 grade&.delete_suffix('%')
               elsif structured
                 grade
               else
                 (grade.present? ? 'other' : nil)
               end,
        non_structured_grade: structured ? nil : grade,
        percentage:,
      )
    end

    def save(application_qualification)
      return false unless valid?

      application_qualification.update!(
        grade: resolved_grade,
      )
    end

    def percentage?
      percentage
    end

    def non_structured?
      grade == 'other'
    end

    def resolved_grade
      if percentage
        "#{grade}%"
      elsif non_structured?
        non_structured_grade
      else
        grade
      end
    end
  end
end
