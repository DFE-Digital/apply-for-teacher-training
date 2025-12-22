require 'rails_helper'

RSpec.describe DataMigrations::UseReferenceDataForNationalities do
  let(:recruitment_cycle_year) { 2026 }

  describe 'where nationalities are outdated' do
    it 'updates the 2026 application forms where nationalities are outdated' do
      old_to_new.each do |old_nationality, new_nationality|
        first_nationality = create(:application_form, recruitment_cycle_year:, first_nationality: old_nationality)
        second_nationality = create(:application_form, recruitment_cycle_year:, second_nationality: old_nationality)

        described_class.new.change
        expect(first_nationality.reload.first_nationality).to eq new_nationality
        expect(second_nationality.reload.second_nationality).to eq new_nationality
      end
    end
  end

  it 'does not update british nationalities' do
    british = create(:application_form, recruitment_cycle_year:, first_nationality: 'British')
    described_class.new.change
    expect(british.reload.first_nationality).to eq 'British'
  end

  it 'does not update older application forms' do
    older_application = create(:application_form, recruitment_cycle_year: 2024, first_nationality: 'Turkish')
    described_class.new.change
    expect(older_application.reload.first_nationality).to eq 'Turkish'
  end

  it 'does not update unchanged nationalities' do
    american = create(:application_form, recruitment_cycle_year:, first_nationality: 'American')
    described_class.new.change
    expect(american.reload.first_nationality).to eq 'American'
  end

private

  def old_to_new
    {
      'Bermudian' => 'Bermudan',
      'Burmese' => 'Citizen of Myanmar',
      'Cayman Islander' => 'Cayman Islander, Caymanian',
      'Congolese (Congo)' => 'Congolese (Republic of the Congo)',
      'Emirati' => 'Citizen of the United Arab Emirates',
      'Hong Konger' => 'Hongkonger or Cantonese',
      'Kittitian' => 'Citizen of St Christopher (St Kitts) and Nevis',
      'Malagasy' => 'Citizen of Madagascar',
      'Mosotho' => 'Citizen of Lesotho',
      'Pitcairn Islander' => 'Pitcairn Islander or Pitcairner',
      'Sammarinese' => 'San Marinese',
      'Tristanian' => 'St Helenian or Tristanian as appropriate. Ascension has no indigenous population',
      'Trinidadian' => 'Trinidad and Tobago citizen',
      'Turkish' => 'Turk, Turkish',
    }
  end
end
