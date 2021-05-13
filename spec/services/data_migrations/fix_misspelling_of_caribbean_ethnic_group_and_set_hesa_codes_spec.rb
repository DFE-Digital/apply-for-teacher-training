require 'rails_helper'

RSpec.describe DataMigrations::FixMisspellingOfCaribbeanEthnicGroupAndSetHesaCodes do
  it 'fixes the misspelled Carribean ethnicity background value' do
    equality_and_diversity = {
      'sex' => 'female',
      'hesa_sex' => '2',
      'disabilities' => [],
      'ethnic_group' => 'Black, African, Black British or Caribbean',
      'hesa_ethnicity' => nil,
      'ethnic_background' => 'Carribean',
    }

    application_form = create(:application_form, equality_and_diversity: equality_and_diversity)

    described_class.new.change

    updated_equality_and_diversity = application_form.reload.equality_and_diversity

    expect(updated_equality_and_diversity['sex']).to eq('female')
    expect(updated_equality_and_diversity['ethnic_background']).to eq('Caribbean')
    expect(updated_equality_and_diversity['hesa_ethnicity']).to eq('21')
  end
end
