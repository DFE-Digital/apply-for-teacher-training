module Hesa
  class DegreeType
    class DegreeTypeStruct
      include ActiveModel::Model
      attr_accessor :id, :priority, :synonyms, :dqt_id, :hesa_code, :abbreviation, :name, :level
      alias hesa_itt_code= hesa_code=

      def shortest_display_name
        abbreviation || name
      end

      def bachelor?
        level == :bachelor
      end
    end

    UNDERGRADUATE_LEVELS = %i[bachelor master].freeze

    class << self
      def all
        DfE::ReferenceData::Degrees::TYPES.all.map { |type_record| DegreeTypeStruct.new(type_record.to_h) }
      end

      def abbreviations_and_names(level: :all)
        case level
        when :all
          all.map { |type| "#{type.abbreviation}|#{type.name}" }
        when :undergraduate
          all
            .select { |type| type.level.in? UNDERGRADUATE_LEVELS }
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
