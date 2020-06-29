module Hesa
  class Institution
    InstitutionStruct = Struct.new(:hesa_code, :name)

    class << self
      def all
        HESA_DEGREE_INSTITUTIONS.map { |subject_data| InstitutionStruct.new(*subject_data) }
      end
    end
  end
end
