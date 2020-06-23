module Hesa
  class DegreeType
    DegreeTypeStruct = Struct.new(:hesa_code, :abbreviation, :name, :level)

    class << self
      def all
        HESA_DEGREE_TYPES.map { |type_data| DegreeTypeStruct.new(*type_data) }
      end

      def abbreviations_and_names
        all.map do |degree_type|
          "#{degree_type.abbreviation}|#{degree_type.name}"
        end
      end

      def find_by_name(name)
        all.find { |degree_type| degree_type.name == name }
      end
    end
  end
end
