require 'rails_helper'

RSpec.describe HesaConverter do
  shared_examples 'convert sex field' do |data|
    it "converts old hesa codes from #{data[:recruitment_cycle_year]} cycle for '#{data[:sex]}' into the most up to date HESA codes" do
      recruitment_cycle_year = data[:recruitment_cycle_year]
      application_form = build(:application_form, :completed)
      application_form.assign_attributes(
        recruitment_cycle_year:,
        equality_and_diversity: application_form.equality_and_diversity.merge(
          hesa_sex: data[:hesa_sex],
          sex: data[:sex],
        ),
      )

      hesa_converter = described_class.new(application_form:, recruitment_cycle_year: current_year)
      expect(hesa_converter.hesa_sex).to eq(
        data[:expected_hesa_sex],
      )
      expect(hesa_converter.sex).to eq(
        data[:expected_sex] || data[:sex],
      )
    end
  end

  # Below I added all scenarios I could catch in the DB from 2020 til 2024
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2020, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: '96', expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2021, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: '96', expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2022, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: '96', expected_sex: 'Prefer not to say' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '1', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '10', sex: 'female', expected_hesa_sex: '10' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '2', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '11', sex: 'male', expected_hesa_sex: '11' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: '3', sex: 'Intersex', expected_hesa_sex: '12', expected_sex: 'other' }
  it_behaves_like 'convert sex field', { recruitment_cycle_year: 2023, hesa_sex: nil, sex: 'Prefer not to say', expected_hesa_sex: '96', expected_sex: 'Prefer not to say' }

  shared_examples 'convert disabilities field' do |data|
    it "converts old HESA codes from #{data[:recruitment_cycle_year]} cycle for '#{data[:disabilities]}' into the most up to date HESA codes" do
      recruitment_cycle_year = data[:recruitment_cycle_year]
      application_form = build(:application_form, :completed)
      application_form.assign_attributes(
        recruitment_cycle_year:,
        equality_and_diversity: application_form.equality_and_diversity.merge(
          hesa_disabilities: data[:hesa_disabilities],
          disabilities: data[:disabilities],
        ),
      )
      hesa_converter = described_class.new(application_form:, recruitment_cycle_year: current_year)
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

  shared_examples 'convert ethnicity field' do |data|
    it "converts old HESA codes from #{data[:recruitment_cycle_year]} cycle for '#{data[:ethnic_background]}' into the most up to date HESA codes" do
      recruitment_cycle_year = data[:recruitment_cycle_year]
      application_form = build(:application_form, :completed)
      application_form.assign_attributes(
        recruitment_cycle_year:,
        equality_and_diversity: application_form.equality_and_diversity.merge(
          hesa_ethnicity: data[:hesa_ethnicity],
          ethnic_background: data[:ethnic_background],
        ),
      )
      hesa_converter = described_class.new(application_form:, recruitment_cycle_year: current_year)
      expect(hesa_converter.hesa_ethnicity).to eq(data[:expected_hesa_ethnicity])
    end
  end

  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '10', ethnic_background: 'White', expected_hesa_ethnicity: '160' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '15', expected_hesa_ethnicity: '163', ethnic_background: 'Gypsy or Traveller' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '21', expected_hesa_ethnicity: '121', ethnic_background: 'Black or Black British - Caribbean' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '22', expected_hesa_ethnicity: '120', ethnic_background: 'Black or Black British - African' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '29', expected_hesa_ethnicity: '139', ethnic_background: 'Other Black background' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '31', expected_hesa_ethnicity: '103', ethnic_background: 'Asian or Asian British - Indian' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '32', expected_hesa_ethnicity: '104', ethnic_background: 'Asian or Asian British - Pakistani' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '33', expected_hesa_ethnicity: '100', ethnic_background: 'Asian or Asian British - Bangladeshi' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '34', expected_hesa_ethnicity: '101', ethnic_background: 'Chinese' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '39', expected_hesa_ethnicity: '119', ethnic_background: 'Other Asian background' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '41', expected_hesa_ethnicity: '142', ethnic_background: 'Mixed - White and Black Caribbean' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '42', expected_hesa_ethnicity: '141', ethnic_background: 'Mixed - White and Black African' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '43', expected_hesa_ethnicity: '140', ethnic_background: 'Mixed - White and Asian' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '49', expected_hesa_ethnicity: '159', ethnic_background: 'Other Mixed background' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '50', expected_hesa_ethnicity: '180', ethnic_background: 'Arab' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '80', expected_hesa_ethnicity: '899', ethnic_background: 'Other Ethnic background' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '90', expected_hesa_ethnicity: '997', ethnic_background: 'Not known' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, hesa_ethnicity: '98', expected_hesa_ethnicity: '998', ethnic_background: 'Prefer not to say' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2023, hesa_ethnicity: nil, ethnic_background: nil, expected_hesa_ethnicity: nil }

  # Free text fields or old ethnic background options from older cycles
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'White', hesa_ethnicity: '10', expected_hesa_ethnicity: '160' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'American', hesa_ethnicity: '10', expected_hesa_ethnicity: '160' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Albaninan', hesa_ethnicity: '10', expected_hesa_ethnicity: '160' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'British, English, Northern Irish, Scottish, or Welsh', hesa_ethnicity: '10', expected_hesa_ethnicity: '160' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Gypsy or Traveller', hesa_ethnicity: '15', expected_hesa_ethnicity: '163' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'African', hesa_ethnicity: '22', expected_hesa_ethnicity: '120' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Asian or Asian British - Pakistani', hesa_ethnicity: '32', expected_hesa_ethnicity: '104' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Other Black background', hesa_ethnicity: '29', expected_hesa_ethnicity: '139' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Another Black background', hesa_ethnicity: '29', expected_hesa_ethnicity: '139' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Indian', hesa_ethnicity: '31', expected_hesa_ethnicity: '103' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Other Asian background', hesa_ethnicity: '39', expected_hesa_ethnicity: '119' }
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2022, ethnic_background: 'Another Asian background', hesa_ethnicity: '39', expected_hesa_ethnicity: '119' }

  # New ethnicity was added in 2023 cycle
  it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2023, hesa_ethnicity: '168', expected_hesa_ethnicity: '168', ethnic_background: 'Roma' }

  HesaEthnicityCollections::HESA_ETHNICITIES_2023_2024.to_h.each do |hesa_code, ethnic_background|
    it_behaves_like 'convert ethnicity field', { recruitment_cycle_year: 2023, hesa_ethnicity: hesa_code, expected_hesa_ethnicity: hesa_code, ethnic_background: ethnic_background }
  end
end
