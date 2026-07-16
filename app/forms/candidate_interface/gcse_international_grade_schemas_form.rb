module CandidateInterface
  class GcseInternationalGradeSchemasForm
    include ActiveModel::Model

    attr_accessor :schema_id

    validates :schema_id, presence: true

    def self.build_from_qualification(qualification)
      new(
        schema_id: qualification.selected_grade_schema_id,
      )
    end

    def save(qualification)
      return false unless valid?

      attributes = {
        selected_grade_schema_id: schema_id,
      }

      if schema_id != qualification.selected_grade_schema_id
        attributes[:grade] = nil
      end

      qualification.update!(attributes)
    end
  end
end
