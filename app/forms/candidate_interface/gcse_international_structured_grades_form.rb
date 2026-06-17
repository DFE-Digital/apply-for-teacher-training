module CandidateInterface
  class GcseInternationalStructuredGradesForm
    include ActiveModel::Model

    attr_accessor :grade, :non_structured_grade

    validates :grade, presence: true
    validates :non_structured_grade, presence: true, if: :non_structured?

    def self.build_from_qualification(application_qualification)
      new(
        grade: application_qualification.grade,
        # TODO: Add flag for conditionally preloading the non_structured_value
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
