module CandidateInterface
  class GcseInternationalGradeSchemasForm
    include ActiveModel::Model

    attr_accessor :schema

    validates :schema, presence: true

    def save(qualification)
      return false unless valid?

      qualification.update!(selected_grade_schema_id: schema)
    end
  end
end
