module HesaIttDataAPIData
  HESA_DISABILITY_OTHER = '96'.freeze

  def hesa_itt_data
    return nil unless ApplicationStateChange::ACCEPTED_STATES.include?(application_choice.status.to_sym)

    equality_and_diversity_data = application_form&.equality_and_diversity

    if equality_and_diversity_data
      {
        sex: equality_and_diversity_data['hesa_sex'],
        disability: equality_and_diversity_data['hesa_disabilities'],
        ethnicity: equality_and_diversity_data['hesa_ethnicity'],
      }.merge(additional_hesa_itt_data(equality_and_diversity_data))
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
    (equality_and_diversity_data['disabilities'] - standard_disabilities).first.presence
  end

  def other_ethnicity_details(equality_and_diversity_data)
    known_ethnic_backgrounds = OTHER_ETHNIC_BACKGROUNDS.values + ETHNIC_BACKGROUNDS.values.flatten + ['Prefer not to say']
    return if known_ethnic_backgrounds.include?(equality_and_diversity_data['ethnic_background'])

    equality_and_diversity_data['ethnic_background']
  end
end
