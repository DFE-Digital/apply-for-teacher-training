module CandidateInterface
  class DegreeGradeForm
    include ActiveModel::Model

    attr_accessor :grade, :other_grade, :degree

    delegate :international?, to: :degree, allow_nil: true

    validates :grade, presence: true
    validates :other_grade, presence: true, if: :other_grade?

    validates :grade, :other_grade, length: { maximum: 255 }

    def save
      return false unless valid?

      submitted_grade = determine_submitted_grade
      hesa_code = Hesa::Grade.find_by_description(submitted_grade)&.hesa_code

      degree.update!(
        grade: determine_submitted_grade,
        grade_hesa_code: hesa_code,
      )
    end

    def fill_form_values
      fill_hesa_form

      self
    end

    INTERNATIONAL_OPTIONS = [
      'Not applicable',
      'Unknown',
    ].freeze

  private

    def fill_hesa_form
      if degree.grade_hesa_code.present?
        hesa_grade = Hesa::Grade.find_by_hesa_code(degree.grade_hesa_code)
        if hesa_grade.visual_grouping == :other
          self.grade = 'other'
          self.other_grade = hesa_grade.description
        else
          self.grade = hesa_grade.description
        end
      else
        self.grade = 'other'
        self.other_grade = degree.grade
      end
    end

    def other_grade?
      grade == 'other'
    end

    def determine_submitted_grade
      if grade == 'other'
        other_grade
      else
        grade
      end
    end
  end
end
