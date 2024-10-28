require 'rails_helper'

RSpec.describe DataMigrations::CorrectHesaEthnicity do
  describe '#change' do
    it 'sets the hesa_ethnicity to 179 without chaning any other keys' do
      form_2023 = create(
        :application_form,
        recruitment_cycle_year: 2023,
        equality_and_diversity: {
          ethnic_group: 'White',
          ethnic_background: 'Another White background',
          hesa_ethnicity: '160',
          sex: 'male',
          hesa_sex: 11,
          disabilities: ['I do not have any of these disabilities or health conditions'],
          free_school_meals: 'Prefer not to say',
          hesa_disabilities: ['95'],
        },
      )

      form_2024 = create(
        :application_form,
        recruitment_cycle_year: 2024,
        equality_and_diversity: {
          ethnic_group: 'White',
          ethnic_background: 'European',
          hesa_ethnicity: '160',
        },
      )

      form_2025 = create(
        :application_form,
        recruitment_cycle_year: 2025,
        equality_and_diversity: {
          ethnic_group: 'White',
          ethnic_background: 'Another White background',
          hesa_ethnicity: '160',
        },
      )

      correct_hesa_ethnicity = create(
        :application_form,
        recruitment_cycle_year: 2024,
        equality_and_diversity: {
          ethnic_group: 'White',
          ethnic_background: 'British, English, Northern Irish, Scottish, or Welsh',
          hesa_ethnicity: '160',
        },
      )

      expect {
        described_class.new.change
      }.to change { form_2023.reload.equality_and_diversity['hesa_ethnicity'] }.from('160').to('179')
        .and change { form_2024.reload.equality_and_diversity['hesa_ethnicity'] }.from('160').to('179')
        .and not_change { form_2023.reload.equality_and_diversity['sex'] }.from('male')
        .and not_change { form_2023.reload.equality_and_diversity['hesa_sex'] }.from(11)
        .and not_change { form_2023.reload.equality_and_diversity['disabilities'] }.from(['I do not have any of these disabilities or health conditions'])
        .and not_change { form_2023.reload.equality_and_diversity['free_school_meals'] }.from('Prefer not to say')
        .and not_change { form_2023.reload.equality_and_diversity['hesa_disabilities'] }.from(['95'])
        .and not_change { form_2025.reload.equality_and_diversity['hesa_ethnicity'] }.from('160')
        .and not_change { correct_hesa_ethnicity.reload.equality_and_diversity['hesa_ethnicity'] }.from('160')
    end
  end
end
