module CandidateInterface
  class HesaCodeBackfill
    HESA_DISABILITY_CODE_OTHER = '96'.freeze
    HESA_ETHNICITY_CODE_REFUSED = '98'.freeze
    HESA_ETHNICITY_CODE_UNKNOWN = '80'.freeze

    def self.call(cycle_year)
      new(cycle_year).call
    end

    def initialize(cycle_year)
      @cycle_year = cycle_year
    end

    def call
      submitted_applications = ApplicationForm.where.not(equality_and_diversity: nil)
                                              .where(recruitment_cycle_year: @cycle_year)

      submitted_applications.each do |application_form|
        fields_to_update = {
          hesa_sex: hesa_sex_code(application_form),
          hesa_disabilities: hesa_disability_codes(application_form),
          hesa_ethnicity: hesa_ethnicity_code(application_form),
        }

        fields_to_update.merge!(application_form.equality_and_diversity)
        application_form.update!(equality_and_diversity: fields_to_update)
      end
    end

  private

    def hesa_ethnicity_code(application_form)
      ethnic_group = application_form.equality_and_diversity['ethnic_group']
      return HESA_ETHNICITY_CODE_REFUSED if @cycle_year == 2020 && ethnic_group == 'Prefer not to say'

      ethnic_background = application_form.equality_and_diversity['ethnic_background']
      hesa_ethnicity_value = Hesa::Ethnicity.convert_to_hesa_value(ethnic_background)

      if ethnic_background
        Hesa::Ethnicity.find_by_value(hesa_ethnicity_value, @cycle_year)&.hesa_code || HESA_ETHNICITY_CODE_UNKNOWN
      end
    end

    def hesa_disability_codes(application_form)
      disabilities = application_form.equality_and_diversity['disabilities']
      return if disabilities.empty?

      disabilities.map do |disability|
        break if disability == 'Prefer not to say'

        hesa_value = Hesa::Disability.convert_to_hesa_value(disability)
        Hesa::Disability.find_by_value(hesa_value)&.hesa_code || HESA_DISABILITY_CODE_OTHER
      end
    end

    def hesa_sex_code(application_form)
      sex = application_form.equality_and_diversity['sex']
      Hesa::Sex.find_by_type(sex)&.hesa_code
    end
  end
end
