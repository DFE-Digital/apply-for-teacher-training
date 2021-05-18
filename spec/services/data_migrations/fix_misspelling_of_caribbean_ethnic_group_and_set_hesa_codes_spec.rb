require 'rails_helper'

RSpec.describe DataMigrations::FixMisspellingOfCaribbeanEthnicGroupAndSetHesaCodes do
  let(:cycle_year) { RecruitmentCycle.current_year }
  let(:equality_and_diversity) do
    {
      'sex' => 'female',
      'hesa_sex' => '2',
      'disabilities' => [],
      'ethnic_group' => 'Black, African, Black British or Caribbean',
      'hesa_ethnicity' => hesa_ethnicity,
      'ethnic_background' => ethnic_background,
    }
  end
  let!(:application_form) { create(:application_form, equality_and_diversity: equality_and_diversity, recruitment_cycle_year: cycle_year) }

  context 'when ethnic_background is set to Carribean' do
    let(:ethnic_background) { 'Carribean' }

    context 'when hesa_ethnicity is already set' do
      let(:hesa_ethnicity) { '1' }

      it 'makes no changes' do
        described_class.new.change

        updated_equality_and_diversity = application_form.reload.equality_and_diversity

        expect(updated_equality_and_diversity['sex']).to eq('female')
        expect(updated_equality_and_diversity['hesa_ethnicity']).to eq('1')
      end
    end

    context 'when hesa_ethnicity is nil' do
      let(:hesa_ethnicity) { nil }

      context 'in the current recruitment_cycle' do
        it 'corrects the spelling mistake and sets the ethnicity code' do
          described_class.new.change

          updated_equality_and_diversity = application_form.reload.equality_and_diversity

          expect(updated_equality_and_diversity['sex']).to eq('female')
          expect(updated_equality_and_diversity['ethnic_background']).to eq('Caribbean')
          expect(updated_equality_and_diversity['hesa_ethnicity']).to eq('21')
        end
      end

      context 'in the previous recruitment_cycle' do
        let(:cycle_year) { RecruitmentCycle.previous_year }

        it 'corrects the spelling mistake and sets the ethnicity code' do
          described_class.new.change

          updated_equality_and_diversity = application_form.reload.equality_and_diversity

          expect(updated_equality_and_diversity['sex']).to eq('female')
          expect(updated_equality_and_diversity['ethnic_background']).to eq('Caribbean')
          expect(updated_equality_and_diversity['hesa_ethnicity']).to eq('21')
        end
      end
    end
  end
end
