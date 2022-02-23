module Hesa
  class DegreeType
    include ActiveModel::Model
    attr_accessor :id, :priority, :qualification, :topic, :synonyms, :dqt_id, :hesa_code, :abbreviation, :name
    alias hesa_itt_code= hesa_code=

    def shortest_display_name
      abbreviation || name
    end

    def bachelor?
      level == :bachelor
    end

    def level
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.one(qualification)&.degree
    end

    UNDERGRADUATE_LEVELS = %i[bachelor master].freeze

    class << self
      def all
        DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.all.map { |type_record| new(type_record.to_h) }
      end

      def abbreviations_and_names(level: :all)
        case level
        when :all
          all.map { |type| "#{type.abbreviation}|#{type.name}" }
        when :undergraduate
          all
            .select { |type| DfE::ReferenceData::Qualifications::QUALIFICATIONS.one(type.qualification)&.degree.in?(UNDERGRADUATE_LEVELS) }
            .map { |type| "#{type.abbreviation}|#{type.name}" }
        end
      end

      def find_by_name(name)
        all.find { |type| type.name == name }
      end

      def find_by_hesa_code(code)
        all.find { |type| type.hesa_code == code }
      end
    end
  end
end
