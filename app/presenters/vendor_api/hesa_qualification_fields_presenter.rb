module VendorAPI
  class HesaQualificationFieldsPresenter
    def initialize(qualification)
      @qualification = qualification
    end

    def to_hash
      return {} unless @qualification.level == 'degree'

      {
        hesa_degtype: @qualification.qualification_type_hesa_code&.to_s.rjust(3, '0'),
        hesa_degsbj: @qualification.subject_hesa_code&.to_s.rjust(6, '0'),
        hesa_degclss: @qualification.grade_hesa_code&.to_s.rjust(2, '0'),
        hesa_degest: @qualification.institution_hesa_code&.to_s.rjust(4, '0'),
        hesa_degctry: @qualification.institution_country&.to_s.rjust(2, '0'),
        hesa_degstdt: "#{@qualification.start_year}-01-01",
        hesa_degenddt: "#{@qualification.award_year}-01-01",
      }
    end
  end
end
