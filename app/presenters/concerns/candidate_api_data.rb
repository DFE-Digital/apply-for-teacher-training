module CandidateAPIData
  include FieldTruncation

  UK_RESIDENCY_STATUS_FIELD = 'Candidate.properties.uk_residency_status'.freeze

  UCAS_FEE_PAYER_CODES = {
    'SLC,SAAS,NIBd,EU,Chl,IoM' => '02',
    'Not Known' => '99',
  }.freeze

  RESIDENCY_CODE = {
    uk_citizen: 'A',
    irish_citizen: 'B',
    no_residency: 'C',
    uk_residency: 'D',
  }.freeze

  delegate :domicile, to: :application_form

  def candidate
    {
      id: application_form.candidate.public_id,
      first_name: application_form.first_name,
      last_name: application_form.last_name,
      date_of_birth: application_form.date_of_birth,
      nationality: application_choice.nationalities,
      domicile:,
      uk_residency_status: truncate_if_over_advertised_limit(UK_RESIDENCY_STATUS_FIELD, uk_residency_status),
      uk_residency_status_code:,
      fee_payer: provisional_fee_payer_status,
      english_main_language: application_form.english_main_language,
      english_language_qualifications: application_form.english_language_qualification_details,
      other_languages: application_form.other_language_details,
      disability_disclosure: application_form.disability_disclosure,
    }
  end

  def uk_residency_status
    return 'UK Citizen' if application_choice.nationalities.include?('GB')
    return 'Irish Citizen' if application_choice.nationalities.include?('IE')
    return FormatResidencyDetailsService.new(application_form:).residency_details_value if application_form.right_to_work_or_study_yes?

    'Candidate needs to apply for permission to work and study in the UK'
  end

  def uk_residency_status_code
    return RESIDENCY_CODE[:uk_citizen] if application_choice.nationalities.include?('GB')
    return RESIDENCY_CODE[:irish_citizen] if application_choice.nationalities.include?('IE')
    return RESIDENCY_CODE[:uk_residency] if application_form.right_to_work_or_study_yes?

    RESIDENCY_CODE[:no_residency]
  end

  def provisional_fee_payer_status
    return UCAS_FEE_PAYER_CODES['SLC,SAAS,NIBd,EU,Chl,IoM'] if provisionally_eligible_for_gov_funding?

    UCAS_FEE_PAYER_CODES['Not Known']
  end

  def provisionally_eligible_for_gov_funding?
    return true if PROVISIONALLY_ELIGIBLE_FOR_GOV_FUNDING_COUNTRY_CODES.intersect?(application_choice.nationalities)

    EU_EEA_SWISS_COUNTRY_CODES.intersect?(application_choice.nationalities) &&
      application_form.right_to_work_or_study_yes? &&
      application_form.uk_address?
  end
end
