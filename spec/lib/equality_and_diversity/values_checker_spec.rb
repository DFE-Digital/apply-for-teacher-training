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

  describe '#converted_equality_and_diversity' do
    context 'valid data' do
      it 'returns equality_and_diversity_hash' do
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

        converted_data = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).converted_equality_and_diversity

        expect(converted_data.keys).to match_array %i[sex disabilities ethnic_background ethnic_group hesa_sex hesa_disabilities hesa_ethnicity]
        expect(converted_data.values.any?(:blank?)).to be false
      end
    end

    context 'invalid data' do
      it 'raises UnexpectedValuesError with helpful message' do
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

        expect {
          described_class.new(
            application_form:,
            recruitment_cycle_year: RecruitmentCycle.current_year,
          ).converted_equality_and_diversity
        }
          .to raise_error(EqualityAndDiversity::UnexpectedValuesError, "The answer(s) for sex, disabilities, and ethnic_background cannot be converted to HESA values for #{RecruitmentCycle.current_year}")
      end
    end

    context 'empty data' do
      it 'raises UnexpectedValuesError with helpful message' do
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity: nil,
        )

        expect {
          described_class.new(
            application_form:,
            recruitment_cycle_year: RecruitmentCycle.current_year,
          ).converted_equality_and_diversity
        }
          .to raise_error(EqualityAndDiversity::UnexpectedValuesError, 'No equality and diversity information provided')
      end
    end
  end
end
