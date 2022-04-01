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
      degree_grade = Hesa::Grade.find_by_description(submitted_grade)
      hesa_code = degree_grade&.hesa_code
      degree_grade_uuid = degree_grade&.id

      degree.update!(
        grade: determine_submitted_grade,
        grade_hesa_code: hesa_code,
        degree_grade_uuid: degree_grade_uuid,
      )
    end

    def assign_form_values
      if international?
        assign_form_values_for_international
      else
        assign_form_values_with_hesa_data_if_available
      end

      self
    end

    NEGATIVE_INTERNATIONAL_OPTIONS = [
      { ui_value: 'No', db_value: 'Not applicable' },
      { ui_value: 'I do not know', db_value: 'Unknown' },
    ].freeze

  private

    def assign_form_values_with_hesa_data_if_available
      return if degree.grade.blank?

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

    def assign_form_values_for_international
      negative_international_option = NEGATIVE_INTERNATIONAL_OPTIONS.find { |o| degree.grade == o.fetch(:db_value) }
      if negative_international_option
        self.grade = negative_international_option.fetch(:ui_value)
      else
        self.grade = 'other'
        self.other_grade = degree.grade
      end
    end

    def other_grade?
      grade == 'other'
    end

    def determine_submitted_grade
      if other_grade?
        other_grade
      else
        map_submitted_grade_to_negative_international_options_if_applicable(grade)
      end
    end

    def map_submitted_grade_to_negative_international_options_if_applicable(submitted_grade)
      negative_international_option = NEGATIVE_INTERNATIONAL_OPTIONS.find { |o| submitted_grade == o.fetch(:ui_value) }
      if negative_international_option
        negative_international_option[:db_value]
      else
        submitted_grade
      end
    end
  end
end
