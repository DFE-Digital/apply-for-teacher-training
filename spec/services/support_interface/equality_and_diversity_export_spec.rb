require 'rails_helper'

RSpec.describe SupportInterface::EqualityAndDiversityExport do
  describe '#data_for_export' do
    it 'returns an array of hashes containing equality and diversity data' do
      one_disability = {
        disabilities: %w[unexplained],
      }

      two_disabilities = {
        sex: 'female',
        ethnic_background: 'Kiwi',
        ethnic_group: 'Cantabrian',
        disabilities: ['unexplained', 'amnesia'],
      }

      application_form_one = create(:completed_application_form, equality_and_diversity: two_disabilities)
      application_form_two = create(:completed_application_form, equality_and_diversity: one_disability)
      create(:completed_application_form, equality_and_diversity: nil)

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          'Month' => application_form_one.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form_one.recruitment_cycle_year,
          'Sex' => application_form_one.equality_and_diversity['sex'],
          'Ethnic background' => application_form_one.equality_and_diversity['ethnic_background'],
          'Ethnic group' => application_form_one.equality_and_diversity['ethnic_group'],
          'Disability 1' => application_form_one.equality_and_diversity['disabilities'].first,
          'Disability 2' => application_form_one.equality_and_diversity['disabilities'].last,
        },
        {
          'Month' => application_form_two.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form_two.recruitment_cycle_year,
          'Sex' => application_form_two.equality_and_diversity['sex'],
          'Ethnic background' => application_form_two.equality_and_diversity['ethnic_background'],
          'Ethnic group' => application_form_two.equality_and_diversity['ethnic_group'],
          'Disability 1' => application_form_two.equality_and_diversity['disabilities'].first,
        },
      )
    end
  end
end
