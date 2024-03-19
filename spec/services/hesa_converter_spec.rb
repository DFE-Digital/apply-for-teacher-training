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

  shared_examples 'convert disabilities field' do |data|
    it "converts old HESA codes from #{data[:recruitment_cycle_year]} cycle for '#{data[:disabilities]}' into the most up to date HESA codes" do
      recruitment_cycle_year = data[:recruitment_cycle_year]
      application_form = create(:application_form, :completed)
      application_form.update!(
        recruitment_cycle_year:,
        equality_and_diversity: application_form.equality_and_diversity.merge(
          hesa_disabilities: data[:hesa_disabilities],
          disabilities: data[:disabilities],
        ),
      )
      hesa_converter = described_class.new(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year)
      expect(hesa_converter.hesa_disabilities).to eq(data[:expected_hesa_disabilities])
      expect(hesa_converter.disabilities).to eq(data[:expected_disabilities])
    end
  end

  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2020, disabilities: nil, hesa_disabilities: nil, expected_hesa_disabilities: nil, expected_disabilities: nil }
  it_behaves_like 'convert disabilities field', {
    recruitment_cycle_year: 2021,
    hesa_disabilities: %w[51 53 54 55 56 57 58 96],
    disabilities: [
      'Learning difficulty',
      'Social or communication impairment',
      'Long-standing illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deaf',
      'Blind',
      'Some other disability',
    ],
    expected_hesa_disabilities: %w[51 53 54 55 56 57 58 96],
    expected_disabilities: [
      'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
      'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
      'Long-term illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deafness or a serious hearing impairment',
      'Blindness or a visual impairment not corrected by glasses',
      'Some other disability',
    ],
  }
  # Converting consciously chosen 'no disabilities' option
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2021, disabilities: [], hesa_disabilities: ['00'], expected_hesa_disabilities: ['95'], expected_disabilities: ['I do not have any of these disabilities or health conditions'] }
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2022, disabilities: [], hesa_disabilities: [], expected_hesa_disabilities: nil, expected_disabilities: nil }
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2022, disabilities: ['Prefer not to say'], hesa_disabilities: [], expected_hesa_disabilities: ['98'], expected_disabilities: ['Prefer not to say'] }
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2022, disabilities: ['Prefer not to say'], hesa_disabilities: nil, expected_hesa_disabilities: ['98'], expected_disabilities: ['Prefer not to say'] }
  it_behaves_like 'convert disabilities field', {
    recruitment_cycle_year: 2022,
    hesa_disabilities: %w[51 53 54 55 56 57 58 96],
    disabilities: [
      'Learning difficulty',
      'Social or communication impairment',
      'Long-standing illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deaf',
      'Blind',
      'Some other disability',
    ],
    expected_hesa_disabilities: %w[51 53 54 55 56 57 58 96],
    expected_disabilities: [
      'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
      'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
      'Long-term illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deafness or a serious hearing impairment',
      'Blindness or a visual impairment not corrected by glasses',
      'Some other disability',
    ],
  }
  it_behaves_like 'convert disabilities field', {
    recruitment_cycle_year: 2023,
    hesa_disabilities: %w[51 53 59 54 55 56 57 58 96],
    disabilities: [
      'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
      'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
      'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood',
      'Long-term illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deafness or a serious hearing impairment',
      'Blindness or a visual impairment not corrected by glasses',
      'Other disability like x',
    ],
    expected_hesa_disabilities: %w[51 53 59 54 55 56 57 58 96],
    expected_disabilities: [
      'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference',
      'Autistic spectrum condition or another condition affecting speech, language, communication or social skills',
      'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood',
      'Long-term illness',
      'Mental health condition',
      'Physical disability or mobility issue',
      'Deafness or a serious hearing impairment',
      'Blindness or a visual impairment not corrected by glasses',
      'Other disability like x',
    ],
  }
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2023, disabilities: ['Some other disability'], hesa_disabilities: ['96'], expected_hesa_disabilities: ['96'], expected_disabilities: ['Some other disability'] }
  it_behaves_like 'convert disabilities field', { recruitment_cycle_year: 2023, disabilities: ['Learning difficulty', 'Some other disability'], hesa_disabilities: %w[51 96], expected_hesa_disabilities: %w[51 96], expected_disabilities: ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference', 'Some other disability'] }

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
