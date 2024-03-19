require 'rails_helper'

RSpec.describe HesaConverter do
  shared_examples 'convert sex field' do |data|
    it "converts old hesa codes from #{data[:recruitment_cycle_year]} cycle for '#{data[:sex]}' into the most up to date HESA codes" do
      recruitment_cycle_year = data[:recruitment_cycle_year]
      application_form = create(:application_form, :completed)
      application_form.update!(
        recruitment_cycle_year:,
        equality_and_diversity: application_form.equality_and_diversity.merge(
          hesa_sex: data[:hesa_sex],
          sex: data[:sex],
        ),
      )

      hesa_converter = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year)
      expect(hesa_converter.hesa_sex).to eq(
        data[:expected_hesa_sex],
      )
      expect(hesa_converter.sex).to eq(
        data[:expected_sex] || data[:sex],
      )
    end
  end

  # Below I added all scenarios I could caught in the DB from 2020 til 2024
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: nil, expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: nil, expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: nil, expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '10', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '11', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: nil, expected_sex: 'Prefer not to say' }

  #    context 'when field is HESA disabilities' do
  #      let(:recruitment_cycle) { RecruitmentCycle.current_year }
  #
  #      before do
  #        @original_application_form.update!(
  #          recruitment_cycle_year: recruitment_cycle,
  #          equality_and_diversity: @original_application_form.equality_and_diversity.merge(
  #            hesa_disabilities:,
  #            disabilities:,
  #          ),
  #        )
  #      end
  #
  #      context 'when nil' do
  #        let(:hesa_disabilities) { nil }
  #        let(:disabilities) { nil }
  #
  #        it 'carries over empty disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(['95'])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(
  #            ['I do not have any of these disabilities or health conditions'],
  #          )
  #        end
  #      end
  #
  #      context 'when empty' do
  #        let(:hesa_disabilities) { [] }
  #        let(:disabilities) { [] }
  #
  #        it 'carries over empty disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(['95'])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(
  #            ['I do not have any of these disabilities or health conditions'],
  #          )
  #        end
  #      end
  #
  #      context 'when converting all default disabilities from 2021' do
  #        let(:recruitment_cycle) { 2021 }
  #        let(:hesa_disabilities) do
  #          HesaDisabilityCollections::HESA_DISABILITIES_2021_2022.map { |hesa| hesa[0] } - ['00']
  #        end
  #        let(:disabilities) do
  #          [
  #            'Learning difficulty',
  #            'Social or communication impairment',
  #            'Long-standing illness',
  #            'Mental health condition',
  #            'Physical disability or mobility issue',
  #            'Deaf',
  #            'Blind',
  #            'Some other disability',
  #          ]
  #        end
  #
  #        it 'carries over disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(
  #            %w[51 53 54 55 56 57 58 96],
  #          )
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to contain_exactly('Autistic spectrum condition or another condition affecting speech, language, communication or social skills', 'Blindness or a visual impairment not corrected by glasses', 'Deafness or a serious hearing impairment', 'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference', 'Long-term illness', 'Mental health condition', 'Physical disability or mobility issue', 'Some other disability')
  #        end
  #      end
  #
  #      context "when converting 'no disabilities' from 2021" do
  #        let(:recruitment_cycle) { 2021 }
  #        let(:hesa_disabilities) { ['00'] }
  #        let(:disabilities) { [] }
  #
  #        it 'carries over disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(['95'])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(
  #            ['I do not have any of these disabilities or health conditions'],
  #          )
  #        end
  #      end
  #
  #      context 'when carry over prefer not to say from 2022' do
  #        let(:recruitment_cycle) { 2022 }
  #        let(:hesa_disabilities) { ['98'] }
  #        let(:disabilities) { [HesaDisabilityValues::PREFER_NOT_TO_SAY] }
  #
  #        it 'carries over disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(['98'])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(
  #            ['Prefer not to say'],
  #          )
  #        end
  #      end
  #
  #      context 'when converting all default disabilities from 2022' do
  #        let(:recruitment_cycle) { 2022 }
  #        let(:hesa_disabilities) do
  #          HesaDisabilityCollections::HESA_DISABILITIES_2022_2023.map { |hesa| hesa[0] }
  #        end
  #        let(:disabilities) do
  #          [
  #            'Learning difficulty',
  #            'Social or communication impairment',
  #            'Long-standing illness',
  #            'Mental health condition',
  #            'Physical disability or mobility issue',
  #            'Deaf',
  #            'Blind',
  #            'Cancer year ago',
  #          ]
  #        end
  #
  #        it 'converts to latest HESA disabilities' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(
  #            %w[51 53 54 55 56 57 58 96],
  #          )
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to contain_exactly(
  #            'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
  #            'Blindness or a visual impairment not corrected by glasses',
  #            'Deafness or a serious hearing impairment',
  #            'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
  #            'Long-term illness',
  #            'Mental health condition',
  #            'Physical disability or mobility issue',
  #            'Cancer year ago',
  #          )
  #        end
  #      end
  #
  #      context 'when converting disabilities from 2023 cycle' do
  #        let(:recruitment_cycle) { 2023 }
  #        let(:hesa_disabilities) { %w[53 58 59 57 51 54 55 56 96] }
  #        let(:disabilities) do
  #          [
  #            'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
  #            'Blindness or a visual impairment not corrected by glasses',
  #            'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood',
  #            'Deafness or a serious hearing impairment',
  #            'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
  #            'Long-term illness',
  #            'Mental health condition',
  #            'Physical disability or mobility issue',
  #            'Other disability like x',
  #          ]
  #        end
  #
  #        it 'carries over and keep the same values' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(hesa_disabilities)
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(disabilities)
  #        end
  #      end
  #
  #      context 'when candidate has other disabilities' do
  #        let(:hesa_disabilities) { ['96'] }
  #        let(:disabilities) { ['Some other disability'] }
  #
  #        it 'carries over and keep the same values' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(['96'])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(disabilities)
  #        end
  #      end
  #
  #      context 'when candidate has a default and other disabilities' do
  #        let(:hesa_disabilities) { %w[51 96] }
  #        let(:disabilities) { ['Learning difficulty', 'Autism'] }
  #
  #        it 'carries over and keep the same values' do
  #          expect(duplicate_application_form.equality_and_diversity['hesa_disabilities']).to eq(%w[51 96])
  #          expect(duplicate_application_form.equality_and_diversity['disabilities']).to eq(
  #            ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference', 'Autism'],
  #          )
  #        end
  #      end
  #    end
  #
  #    context 'when field is HESA ethnicities' do
  #      context 'when ethnic background is nil' do
  #        it 'carries over as the same ethnic data for' do
  #          @original_application_form.update!(
  #            recruitment_cycle_year: 2023,
  #            equality_and_diversity: @original_application_form.equality_and_diversity.merge(
  #              hesa_ethnicity: nil,
  #              ethnic_background: nil,
  #            ),
  #          )
  #
  #          expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to be_nil
  #          expect(duplicate_application_form.equality_and_diversity['ethnic_background']).to be_nil
  #        end
  #      end
  #
  #      context 'when 2022 cycle application' do
  #        [
  #          { hesa_code: '10', expected_conversion: '160', ethnic_background: 'White' },
  #          { hesa_code: '15', expected_conversion: '163', ethnic_background: 'Gypsy or Traveller' },
  #          { hesa_code: '21', expected_conversion: '121', ethnic_background: 'Black or Black British - Caribbean' },
  #          { hesa_code: '22', expected_conversion: '120', ethnic_background: 'Black or Black British - African' },
  #          { hesa_code: '29', expected_conversion: '139', ethnic_background: 'Other Black background' },
  #          { hesa_code: '31', expected_conversion: '103', ethnic_background: 'Asian or Asian British - Indian' },
  #          { hesa_code: '32', expected_conversion: '104', ethnic_background: 'Asian or Asian British - Pakistani' },
  #          { hesa_code: '33', expected_conversion: '100', ethnic_background: 'Asian or Asian British - Bangladeshi' },
  #          { hesa_code: '34', expected_conversion: '101', ethnic_background: 'Chinese' },
  #          { hesa_code: '39', expected_conversion: '119', ethnic_background: 'Other Asian background' },
  #          { hesa_code: '41', expected_conversion: '142', ethnic_background: 'Mixed - White and Black Caribbean' },
  #          { hesa_code: '42', expected_conversion: '141', ethnic_background: 'Mixed - White and Black African' },
  #          { hesa_code: '43', expected_conversion: '140', ethnic_background: 'Mixed - White and Asian' },
  #          { hesa_code: '49', expected_conversion: '159', ethnic_background: 'Other Mixed background' },
  #          { hesa_code: '50', expected_conversion: '180', ethnic_background: 'Arab' },
  #          { hesa_code: '80', expected_conversion: '899', ethnic_background: 'Other Ethnic background' },
  #          { hesa_code: '90', expected_conversion: '997', ethnic_background: 'Not known' },
  #          { hesa_code: '98', expected_conversion: '998', ethnic_background: 'Prefer not to say' },
  #        ].each do |ethnic_data|
  #          it "carries over #{ethnic_data[:ethnic_background]} to HESA code '#{ethnic_data[:expected_conversion]}'" do
  #            @original_application_form.update!(
  #              recruitment_cycle_year: 2022,
  #              equality_and_diversity: @original_application_form.equality_and_diversity.merge(
  #                hesa_ethnicity: ethnic_data[:hesa_code],
  #                ethnic_background: ethnic_data[:ethnic_background],
  #              ),
  #            )
  #
  #            expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to eq(ethnic_data[:expected_conversion])
  #          end
  #        end
  #      end
  #
  #      context 'when new added fields between cycles like "Roma"' do
  #        [
  #          { hesa_code: '168', expected_conversion: '168', ethnic_background: 'Roma' },
  #        ].each do |ethnic_data|
  #          it "carries over #{ethnic_data[:ethnic_background]} to HESA code '#{ethnic_data[:expected_conversion]}'" do
  #            @original_application_form.update!(
  #              recruitment_cycle_year: 2023,
  #              equality_and_diversity: @original_application_form.equality_and_diversity.merge(
  #                hesa_ethnicity: ethnic_data[:hesa_code],
  #                ethnic_background: ethnic_data[:ethnic_background],
  #              ),
  #            )
  #
  #            expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to eq(ethnic_data[:expected_conversion])
  #          end
  #        end
  #      end
  #
  #      context 'when 2023 cycle application' do
  #        HesaEthnicityCollections::HESA_ETHNICITIES_2023_2024.to_h.each do |hesa_code, ethnic_background|
  #          it "carries over as the same ethnic data for '#{ethnic_background}'" do
  #            @original_application_form.update!(
  #              recruitment_cycle_year: 2023,
  #              equality_and_diversity: @original_application_form.equality_and_diversity.merge(
  #                hesa_ethnicity: hesa_code,
  #                ethnic_background: ethnic_background,
  #              ),
  #            )
  #
  #            expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to eq(hesa_code)
  #            expect(duplicate_application_form.equality_and_diversity['ethnic_background']).to eq(ethnic_background)
  #          end
  #        end
  #      end
  #    end
end
