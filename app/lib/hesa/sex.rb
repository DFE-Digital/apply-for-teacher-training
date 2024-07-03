module Hesa
  class Sex
    SexStruct = Struct.new(:hesa_code, :type)

    def self.all(cycle_year)
      collection_name = "#{cycle_year - 1}_#{cycle_year}"
      collection = HESA_SEX_COLLECTIONS[collection_name] || HESA_SEX_COLLECTIONS[HESA_SEX_COLLECTIONS.keys.max]

      collection.map { |sex| SexStruct.new(*sex) }
    end

    def self.find(sex, cycle_year)
      # The gymnastics here are required because we use 'Prefer not to say' as the value AND label on the SexForm.
      # We have a ticket to change this (the value should be 'information refused'), and when we do, we can simplify this little mess
      if sex == 'prefer not to say'
        result = all(cycle_year).find { |hesa_sex| hesa_sex.type == 'information refused' }
        result.type = 'Prefer not to say'
        return result
      end

      if sex == 'intersex'
        sex = 'other'
      end

      all(cycle_year).find { |hesa_sex| hesa_sex.type == sex }
    end
  end
end
