module Hesa
  class Sex
    SexStruct = Struct.new(:hesa_code, :type)

    def self.all
      HESA_SEX.map { |sex| SexStruct.new(*sex) }
    end

    def self.find_by_type(sex_type)
      all.find { |sex| sex.type == sex_type }
    end
  end
end
