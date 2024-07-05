require 'rails_helper'

RSpec.describe EqualityAndDiversity::ValuesChecker do
  let(:disability_options) do
    (HesaDisabilityCollections::HESA_DISABILITIES_2020_2021 +
      HesaDisabilityCollections::HESA_DISABILITIES_2023_2024).map { |_hesa_code, label, _uuid| label }
  end

  let(:ethnic_backgrounds) do
    (HesaEthnicityCollections::HESA_ETHNICITIES_2020_2021 +
      HesaEthnicityCollections::HESA_ETHNICITIES_2023_2024).map { |_hesa_code, label, _uuid| label }
  end

  let(:sexes) { ['female', 'male', 'other', 'intersex', 'Prefer not to say'] }

  let(:ethnic_groups) { EthnicGroup.all }

  describe '#check' do
    context 'valid data' do
      it 'returns true' do
        equality_and_diversity = {
          sex: sexes.sample,
          disabilities: [disability_options.sample(2)],
          ethnic_background: ethnic_backgrounds.sample,
          ethnic_group: ethnic_groups.sample,
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        check = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).check
        expect(check).to be true
      end
    end

    context 'prefer not say data, ethnic_background blank' do
      it 'returns true' do
        equality_and_diversity = {
          sex: 'Prefer not to say',
          disabilities: 'Prefer not to say',
          ethnic_group: 'Prefer not to say',
          ethnic_background: nil,
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        check = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).check
        expect(check).to be true
      end
    end

    context 'prefer not to say data, ethnic_group blank' do
      it 'returns true' do
        equality_and_diversity = {
          sex: 'Prefer not to say',
          disabilities: 'Prefer not to say',
          ethnic_group: nil,
          ethnic_background: 'Prefer not to say',
        }

        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        check = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).check
        expect(check).to be true
      end
    end

    context 'incomplete data' do
      it 'returns false' do
        equality_and_diversity = {
          disabilities: [disability_options.sample(2)],
          ethnic_group: ethnic_groups.sample,
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        check = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).check
        expect(check).to be false
      end
    end

    context 'invalid data' do
      it 'returns false' do
        equality_and_diversity = {
          sex: 'sex or gender',
          disabilities: nil,
          ethnic_group: 'ethnic group',
          ethnic_background: 'ethnic background',
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        check = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).check
        expect(check).to be false
      end
    end
  end
end
