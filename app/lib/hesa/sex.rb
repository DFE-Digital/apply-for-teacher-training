module Hesa
  class Sex
    SexStruct = Struct.new(:hesa_code, :type)

    def self.all(cycle_year)
      collection_name = "HESA_SEX_#{cycle_year - 1}_#{cycle_year}"
      HesaSexCollections.const_get(collection_name).map { |sex| SexStruct.new(*sex) }
    rescue NameError
      raise ArgumentError, "Do not know Hesa Sex codes for #{cycle_year}"
    end

    def self.find(sex, cycle_year = RecruitmentCycle.current_year)
      if sex == 'intersex'
        sex = 'other'
      end

      all(cycle_year).find { |hesa_sex| hesa_sex.type == sex }
    end
  end
end
