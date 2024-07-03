require 'rails_helper'

RSpec.describe EqualityAndDiversity::ValuesBuilder do
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

  describe '#call' do
    context 'with valid and complete data' do
      it 'returns complete values' do
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

        result = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call

        expect(result.equality_and_diversity_completed).to be true
        expect(result.equality_and_diversity.values.any?(&:blank?)).to be false
        expect(result.equality_and_diversity.keys)
          .to match_array(
            %i[sex disabilities ethnic_background ethnic_group hesa_sex hesa_disabilities hesa_ethnicity],
          )
      end
    end

    context 'with valid but incomplete data' do
      it 'raises unexpected value error' do
        equality_and_diversity = {
          disabilities: [disability_options.sample(2)],
          ethnic_group: ethnic_groups.sample,
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        expect { described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call }
          .to raise_error(EqualityAndDiversity::UnexpectedValuesError, "The answer(s) for sex and ethnic_background cannot be converted to HESA values for #{RecruitmentCycle.current_year}")
      end
    end

    context 'with some invalid data' do
      it 'raises unexpected value error' do
        equality_and_diversity = {
          sex: sexes.sample,
          disabilities: nil,
          ethnic_group: ethnic_groups.sample,
          ethnic_background: 'ethnic background',
        }
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity:,
        )

        expect { described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call }
          .to raise_error(EqualityAndDiversity::UnexpectedValuesError, "The answer(s) for disabilities and ethnic_background cannot be converted to HESA values for #{RecruitmentCycle.current_year}")
      end
    end

    context 'with empty data' do
      it 'raises error' do
        application_form = create(
          :application_form,
          recruitment_cycle_year: RecruitmentCycle.previous_year,
          equality_and_diversity: nil,
        )

        expect { described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call }
          .to raise_error(EqualityAndDiversity::UnexpectedValuesError, 'No equality and diversity information provided')
      end
    end

    context 'Prefer not to say / information refused' do
      describe 'Ethnic background is blank' do
        it 'returns complete data with ethnic background set to nil, all other values are set' do
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

          result = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call

          expect(result.equality_and_diversity_completed).to be true
          expect(result.equality_and_diversity[:ethnic_background]).to be_nil
          expect(result.equality_and_diversity.except(:ethnic_background).values.any?(&:blank?)).to be false
          expect(result.equality_and_diversity.keys)
            .to match_array(
              %i[sex disabilities ethnic_background ethnic_group hesa_sex hesa_disabilities hesa_ethnicity],
            )
        end
      end

      describe 'Ethnic group is blank' do
        it 'returns complete data' do
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

          result = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year).call

          expect(result.equality_and_diversity_completed).to be true
          expect(result.equality_and_diversity.except(:ethnic_group).values.any?(&:blank?)).to be false
          expect(result.equality_and_diversity[:ethnic_group]).to eq 'Prefer not to say'
          expect(result.equality_and_diversity.keys)
            .to match_array(
              %i[sex disabilities ethnic_background ethnic_group hesa_sex hesa_disabilities hesa_ethnicity],
            )
        end
      end
    end
  end
end
