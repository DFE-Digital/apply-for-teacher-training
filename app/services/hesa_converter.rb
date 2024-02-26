class HesaConverter
  attr_reader :application_form, :recruitment_cycle_year

  def initialize(application_form:, recruitment_cycle_year:)
    @application_form = application_form
    @recruitment_cycle_year = recruitment_cycle_year
    @application_form_sex = application_form.equality_and_diversity['sex'].to_s
  end

  def hesa_sex
    hesa_sex_data&.hesa_code
  end

  def sex
    hesa_sex_data&.type || @application_form_sex
  end

  def hesa_disabilities
    converted_disabilities[:hesa_disabilities]
  end

  def disabilities
    converted_disabilities[:disabilities]
  end

  def hesa_ethnicity
    if @application_form.equality_and_diversity['ethnic_background'].present?
      Hesa::Ethnicity.all(@recruitment_cycle_year).find do |ethnicity|
        ethnicity.value == @application_form.equality_and_diversity['ethnic_background']
      end&.hesa_code
    end
  end

private

  def hesa_sex_data
    @hesa_sex_data ||= Hesa::Sex.find(
      @application_form_sex.downcase,
      @recruitment_cycle_year,
    )
  end

  def converted_disabilities
    if @application_form.equality_and_diversity['disabilities'].blank?
      no_disability = Hesa::Disability.find('I do not have any of these disabilities or health conditions', @recruitment_cycle_year)

      hesa_disabilities = [no_disability.hesa_code]
      disabilities = ['I do not have any of these disabilities or health conditions']
    else
      disabilities = Hesa::Disability.convert_disabilities(@application_form.equality_and_diversity['disabilities'])

      converted_hesa_data = disabilities.map { |disability| Hesa::Disability.find(disability) }
      hesa_disabilities = converted_hesa_data.map(&:hesa_code)
    end

    {
      hesa_disabilities:,
      disabilities:,
    }
  end
end
