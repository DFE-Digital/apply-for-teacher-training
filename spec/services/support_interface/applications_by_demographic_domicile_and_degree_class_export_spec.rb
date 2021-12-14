require 'rails_helper'

RSpec.describe SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport do
  describe '#call' do
    around do |example|
      Timecop.freeze(2021, 11, 24) do
        example.run
      end
    end

    before do
      create(:completed_application_form,
             date_of_birth: '1999-09-05',
             country: 'GB',
             equality_and_diversity: {
               'sex' => 'male',
               'hesa_sex' => '1',
               'disabilities' => ['Learning difficulty', 'Social or communication impairment', 'Blind'],
               'ethnic_group' => 'Another ethnic group',
               'hesa_ethnicity' => '50',
               'ethnic_background' => 'Arab',
               'hesa_disabilities' => %w[51 53 58],
             },
             application_choices: [
               create(:application_choice, status: :pending_conditions),
             ],
             application_qualifications: [
               create(:application_qualification, level: 'degree', grade: 'Pass'),
               create(:application_qualification, level: 'degree', grade: 'Lower second-class honours (2:2)'),
             ])
    end

    it 'returns counts for a single application with highest degree grade' do
      result = described_class.new.data_for_export

      expect(result).to match_array([
        {
          age_group: 'Under 25',
          sex: 'Male',
          ethnicity: '50',
          disability: 'Two or more impairments and/or disabling medical conditions',
          degree_class: 'Lower second-class honours (2:2)',
          domicile: 'UK',
          pending_conditions: 1,
          recruited: 0,
          total: 1,
        },
      ])
    end

    it 'returns combined and distinct counts for a multiple applications' do
      create(:completed_application_form,
             date_of_birth: '1992-07-05',
             country: 'DE',
             equality_and_diversity: {
               'sex' => 'female',
               'hesa_sex' => '2',
               'disabilities' => ['Blind'],
               'ethnic_group' => 'Another ethnic group',
               'hesa_ethnicity' => '90',
               'ethnic_background' => 'Not known',
               'hesa_disabilities' => ['58'],
             },
             application_choices: [
               create(:application_choice, status: :pending_conditions),
             ],
             application_qualifications: [
               create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)'),
             ])
      create(:completed_application_form,
             date_of_birth: '1987-08-20',
             country: 'DE',
             equality_and_diversity: {
               'sex' => 'female',
               'hesa_sex' => '2',
               'disabilities' => ['Blind'],
               'ethnic_group' => 'Another ethnic group',
               'hesa_ethnicity' => '90',
               'ethnic_background' => 'Not known',
               'hesa_disabilities' => ['58'],
             },
             application_choices: [
               create(:application_choice, status: :recruited),
             ],
             application_qualifications: [
               create(:application_qualification, level: 'degree', grade: 'Upper second-class honours (2:1)'),
             ])
      result = described_class.new.data_for_export

      expect(result).to match_array([
        {
          age_group: 'Under 25',
          sex: 'Male',
          ethnicity: '50',
          disability: 'Two or more impairments and/or disabling medical conditions',
          degree_class: 'Lower second-class honours (2:2)',
          domicile: 'UK',
          pending_conditions: 1,
          recruited: 0,
          total: 1,
        },
        {
          age_group: '30 to 34',
          sex: 'Female',
          ethnicity: '90',
          disability: '58',
          degree_class: 'Upper second-class honours (2:1)',
          domicile: 'EU',
          pending_conditions: 1,
          recruited: 1,
          total: 2,
        },
      ])
    end
  end
end
