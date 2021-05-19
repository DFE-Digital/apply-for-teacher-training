require 'rails_helper'

RSpec.describe DataMigrations::RemoveIncorrectHesaCodes do
  def application_with_ethnicity_code(ethnic_group, ethnic_background, hesa_ethnicity)
    create(
      :application_form,
      equality_and_diversity: { 'ethnic_group': ethnic_group, 'ethnic_background': ethnic_background, 'hesa_ethnicity': hesa_ethnicity },
    )
  end

  def application_with_disability_codes(disabilities, hesa_disabilities)
    create(
      :application_form,
      equality_and_diversity: { disabilities: disabilities, hesa_disabilities: hesa_disabilities },
    )
  end

  it 'corrects any applications that have redundant HESA disability codes', with_audited: true do
    valid_application_form = application_with_disability_codes(
      %w[Deaf Blind],
      %w[Deaf Blind].map { |disability| Hesa::Disability.find(disability)&.hesa_code },
    )
    invalid_application_form = application_with_disability_codes(
      ['Prefer not to say'],
      %w[Deaf Blind].map { |disability| Hesa::Disability.find(disability)&.hesa_code },
    )

    described_class.new.change

    expect(valid_application_form.reload.equality_and_diversity['hesa_disabilities']).to eq(
      %w[Deaf Blind].map { |disability| Hesa::Disability.find(disability)&.hesa_code },
    )
    expect(invalid_application_form.reload.equality_and_diversity['hesa_disabilities']).to eq([])
    audit_entry = invalid_application_form.audits.last
    expect(audit_entry.comment).to eq('Resetting incorrect HESA disability codes. See https://trello.com/c/U7W3r0tj/3402')
  end

  it 'corrects any applications that have a redundant HESA ethnicity code', with_audited: true do
    valid_application_form = application_with_ethnicity_code(
      'Asian or Asian British',
      HesaEthnicityValues::CHINESE,
      '34',
    )
    invalid_application_form = application_with_ethnicity_code(
      'Prefer not to say',
      nil,
      '34',
    )

    described_class.new.change

    expect(valid_application_form.reload.equality_and_diversity['hesa_ethnicity']).to eq('34')
    expect(invalid_application_form.reload.equality_and_diversity['hesa_ethnicity']).to eq(nil)
    audit_entry = invalid_application_form.audits.last
    expect(audit_entry.comment).to eq('Resetting incorrect HESA ethnicity code. See https://trello.com/c/U7W3r0tj/3402')
  end
end
