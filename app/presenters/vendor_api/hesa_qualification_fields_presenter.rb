module VendorAPI
  class HesaQualificationFieldsPresenter
    def initialize(qualification)
      @qualification = qualification
    end

    def to_hash
      return {} unless @qualification.level == 'degree'

      {
        hesa_degtype: @qualification.qualification_type_hesa_code,
        hesa_degsbj: @qualification.subject_hesa_code,
        hesa_degclss: @qualification.grade_hesa_code,
        hesa_degest: @qualification.institution_hesa_code,
        hesa_degctry: @qualification.institution_country,
        hesa_degstdt: "#{@qualification.start_year}-01-01",
        hesa_degenddt: "#{@qualification.award_year}-01-01",
      }
    end
  end
end
