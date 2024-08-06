module Hesa
  class Sex
    SexStruct = Struct.new(:hesa_code, :type)

    def self.all(cycle_year)
      collection_name = "#{cycle_year - 1}_#{cycle_year}"
      collection = HESA_SEX_COLLECTIONS[collection_name] || HESA_SEX_COLLECTIONS[HESA_SEX_COLLECTIONS.keys.max]

      collection.map { |sex| SexStruct.new(*sex) }
    end

    def self.find(sex, cycle_year)
      if sex == 'intersex'
        sex = 'other'
      end

      all(cycle_year).find { |hesa_sex| hesa_sex.type == sex }
    end

    def self.sex_label(value, cycle_year)
      type = find(value, cycle_year)&.type

      if type == I18n.t('equality_and_diversity.sex.opt_out.value')
        I18n.t('equality_and_diversity.sex.opt_out.label')
      else
        value.capitalize
      end
    end
  end
end
