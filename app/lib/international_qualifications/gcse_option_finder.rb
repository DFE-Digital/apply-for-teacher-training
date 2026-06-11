module InternationalQualifications
  class GcseOptionFinder
    def initialize(country_code)
      @country_code = country_code
    end

    attr_reader :country_code

    def qualification
      @qualification ||= qualifications.find do |option|
        option.countries.include?(country_code)
      end
    end

    def grade_schemas
      @grade_schemas ||= grades.filter do |grade|
        grade.id.in?(qualification.grade_options)
      end
    end

    def qualifications
      DfE::ReferenceData::International::Qualifications::QUALIFICATIONS.all_as_hash.values
    end

    def grades
      DfE::ReferenceData::International::Grades::GRADES.all_as_hash.values
    end
  end
end
