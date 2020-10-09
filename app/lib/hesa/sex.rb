module Hesa
  class Sex
    SexStruct = Struct.new(:hesa_code, :type)

    def self.all
      HESA_SEX.map { |sex| SexStruct.new(*sex) }
    end

    def self.find(sex)
      if sex == 'intersex'
        sex = 'other'
      end

      all.find { |hesa_sex| hesa_sex.type == sex }
    end
  end
end
