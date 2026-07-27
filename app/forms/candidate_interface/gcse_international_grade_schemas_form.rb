module CandidateInterface
  class GcseInternationalGradeSchemasForm
    include ActiveModel::Model

    attr_accessor :schema_id, :grade

    validates :schema_id, presence: true

    validates :grade, presence: true, if: :other?
    validates :grade, length: { maximum: 20 }, if: :other?

    def self.build_from_qualification(qualification)
      new(
        schema_id: qualification.selected_grade_schema_id.presence || (qualification.grade.present? ? 'other' : nil),
        grade: qualification.selected_grade_schema_id.present? ? nil : qualification.grade,
      )
    end

    def save(qualification)
      return false unless valid?

      if other?
        qualification.update!(
          selected_grade_schema_id: nil,
          grade: grade,
        )
      else
        attributes = {
          selected_grade_schema_id: schema_id,
        }

        if schema_id != qualification.selected_grade_schema_id
          attributes[:grade] = nil
        end

        qualification.update!(attributes)
      end
    end

    def other?
      schema_id == 'other'
    end
  end
end
