module Hesa
  class DegreeType
    DegreeTypeStruct = Struct.new(:hesa_code, :abbreviation, :name, :level) do
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
        HESA_DEGREE_TYPES.map { |type_data| DegreeTypeStruct.new(*type_data) }
      end

      def abbreviations_and_names(level: :all)
        case level
        when :all
          all
            .map { |type| "#{type.abbreviation}|#{type.name}" }
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
