class HesaConverter
  def initialize(application_form:, recruitment_cycle_year:)
    @application_form = application_form
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def hesa_sex
    hesa_sex_data&.hesa_code
  end

  def sex
    hesa_sex_data&.type || application_form_sex
  end

  def hesa_disabilities
    hesa_disabilities_data[:hesa_disabilities]
  end

  def disabilities
    hesa_disabilities_data[:disabilities]
  end

  def hesa_ethnicity
    ethnicity_data[:hesa_ethnicity]
  end

private

  attr_reader :application_form, :recruitment_cycle_year
  delegate :equality_and_diversity, to: :application_form

  def application_form_sex
    @application_form_sex ||= equality_and_diversity['sex'].to_s
  end

  def application_form_disabilities
    @application_form_disabilities ||= equality_and_diversity['disabilities']
  end

  def hesa_sex_data
    @hesa_sex_data ||= Hesa::Sex.find(application_form_sex.downcase, recruitment_cycle_year)
  end

  def hesa_disabilities_data
    return {} unless candidate_chosen_no_disabilities? || application_form_disabilities.present?

    if candidate_chosen_no_disabilities?
      no_disability = Hesa::Disability.no_disability(recruitment_cycle_year: recruitment_cycle_year)

      {
        hesa_disabilities: [no_disability.hesa_code],
        disabilities: [I18n.t('equality_and_diversity.disabilities.no.label')],
      }
    else
      disabilities = Hesa::Disability.convert_disabilities(application_form_disabilities)
      converted_hesa_data = disabilities.map { |disability| Hesa::Disability.find(disability) }
      hesa_disabilities = converted_hesa_data.map(&:hesa_code)

      {
        hesa_disabilities:,
        disabilities:,
      }
    end
  end

  def ethnicity_data
    return {} if ethnic_look_up_value.blank?

    hesa_code = Hesa::Ethnicity.find_without_conversion(
      ethnic_look_up_value,
      recruitment_cycle_year,
    )&.hesa_code

    if hesa_code.blank? && equality_and_diversity['hesa_ethnicity'].present?
      ethnic_value = HesaEthnicityCollections::HESA_ETHNICITIES_2019_2020.to_h[equality_and_diversity['hesa_ethnicity']]
      hesa_code = Hesa::Ethnicity.find_without_conversion(ethnic_value, recruitment_cycle_year)&.hesa_code
    end

    {
      hesa_ethnicity: hesa_code || equality_and_diversity['hesa_ethnicity'],
    }
  end

  def ethnic_look_up_value
    if equality_and_diversity['ethnic_group'] == 'Prefer not to say' && equality_and_diversity['ethnic_background'].blank?
      'Prefer not to say'
    else
      equality_and_diversity['ethnic_background']
    end
  end

  def candidate_chosen_no_disabilities?
    Array(equality_and_diversity['hesa_disabilities']) == ['00']
  end
end
