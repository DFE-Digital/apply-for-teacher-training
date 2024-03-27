module HesaIttDataAPIData
  HESA_CODES_UPDATE_YEAR = 2023
  HESA_DISABILITY_OTHER = '96'.freeze

  def hesa_itt_data
    return nil unless ApplicationStateChange.accepted.include?(application_choice.status.to_sym)

    unless (data = application_form&.equality_and_diversity).nil?
      hesa_codes(data).merge(additional_hesa_itt_data(data))
    end
  end

  def additional_hesa_itt_data(equality_and_diversity_data)
    {
      other_disability_details: other_disability_details(equality_and_diversity_data),
      other_ethnicity_details: other_ethnicity_details(equality_and_diversity_data),
    }
  end

  def other_disability_details(equality_and_diversity_data)
    return unless equality_and_diversity_data['hesa_disabilities']&.include?(HESA_DISABILITY_OTHER)

    standard_disabilities = DisabilityHelper::STANDARD_DISABILITIES.map(&:last)
    (equality_and_diversity_data['disabilities'] - standard_disabilities).last.presence
  end

  def other_ethnicity_details(equality_and_diversity_data)
    known_ethnic_backgrounds = OTHER_ETHNIC_BACKGROUNDS.values + ETHNIC_BACKGROUNDS.values.flatten + ['Prefer not to say']
    return if known_ethnic_backgrounds.include?(equality_and_diversity_data['ethnic_background'])

    equality_and_diversity_data['ethnic_background']
  end

  def hesa_codes(equality_and_diversity_data)
    if application_form.recruitment_cycle_year >= HESA_CODES_UPDATE_YEAR
      {
        disability: [],
        ethnicity: nil,
        sex: nil,
      }
    else
      {
        disability: equality_and_diversity_data['hesa_disabilities'],
        ethnicity: equality_and_diversity_data['hesa_ethnicity'],
        sex: equality_and_diversity_data['hesa_sex'],
      }
    end
  end
end
