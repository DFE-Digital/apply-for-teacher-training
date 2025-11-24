module CandidateInterface
  class HesaCodeBackfill
    HESA_DISABILITY_CODE_OTHER = '96'.freeze
    HESA_ETHNICITY_CODE_REFUSED = 98
    HESA_ETHNICITY_CODE_UNKNOWN = 90

    def self.call(cycle_year)
      new(cycle_year).call
    end

    def initialize(cycle_year)
      @cycle_year = cycle_year
    end

    def call
      submitted_applications = ApplicationForm.where.not(equality_and_diversity: nil)
                                              .where(recruitment_cycle_year: @cycle_year)

      submitted_applications.find_each do |application_form|
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

      if ethnic_group == 'Prefer not to say'
        return Hesa::Ethnicity.find(ethnic_group, @cycle_year)&.hesa_code
      end

      ethnic_background = application_form.equality_and_diversity['ethnic_background']

      if ethnic_background
        Hesa::Ethnicity.find(ethnic_background, @cycle_year)&.hesa_code
      end
    end

    def hesa_disability_codes(application_form)
      disabilities = application_form.equality_and_diversity['disabilities']
      return if disabilities.blank?

      codes = disabilities.map do |disability|
        break if disability == 'Prefer not to say'

        Hesa::Disability.find(disability)&.hesa_code
      end

      codes.presence&.uniq
    end

    def hesa_sex_code(application_form)
      sex = application_form.equality_and_diversity['sex']

      Hesa::Sex.find(sex, current_year)&.hesa_code
    end

    def current_year
      @current_year ||= RecruitmentCycleTimetable.current_year
    end
  end
end
