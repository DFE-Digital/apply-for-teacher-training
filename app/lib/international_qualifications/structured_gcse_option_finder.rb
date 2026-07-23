module InternationalQualifications
  class StructuredGcseOptionFinder
    GcseOption = Data.define(:name, :countries, :grade_schemas)

    def initialize(country_code, subject)
      @country_code = country_code.upcase
      @subject = subject
    end

    attr_reader :country_code, :subject

    def equivalent_qualifications
      @equivalent_qualifications ||= international_qualifications.map do |qual|
        GcseOption.new(
          name: qual.name,
          countries: qual.countries,
          grade_schemas: grade_schemas(qual),
        )
      end
    end

    def grade_schemas(qualification)
      grades.filter do |grade|
        grade.id.in?(qualification.grade_options)
      end
    end

    def international_qualifications
      @international_qualifications ||= DfE::ReferenceData::International::Qualifications::QUALIFICATIONS.all_as_hash.values.filter do |option|
        option.countries.include?(country_code) && option.subjects.include?(subject)
      end
    end

    def grades
      DfE::ReferenceData::International::Grades::GRADES.all_as_hash.values
    end
  end
end
