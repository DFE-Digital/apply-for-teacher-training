module Hesa
  class Institution
    InstitutionStruct = Struct.new(:hesa_code, :name)

    class << self
      def all
        HESA_DEGREE_INSTITUTIONS.map { |institution_data| InstitutionStruct.new(*institution_data) }
      end

      def names
        all.map(&:name)
      end

      def find_by_name(name)
        all.find { |institution| institution.name == name }
      end
    end
  end
end
