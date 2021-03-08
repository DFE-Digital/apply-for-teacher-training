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
        disabilities: %w[unexplained amnesia],
      }

      three_disabilities = {
        sex: 'female',
        ethnic_background: 'Kiwi',
        ethnic_group: 'Cantabrian',
        disabilities: %w[unexplained amnesia blind],
      }

      application_form_one = create(:completed_application_form, equality_and_diversity: two_disabilities)
      application_form_two = create(:completed_application_form, equality_and_diversity: one_disability)
      application_form_three = create(:completed_application_form, equality_and_diversity: three_disabilities)

      create(:completed_application_form, equality_and_diversity: nil)
      create(
        :application_choice,
        :with_structured_rejection_reasons,
        structured_rejection_reasons: {
          course_full_y_n: 'No',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_other: 'Persistent scratching',
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns: %w[references],
        },
        application_form: application_form_two,
      )

      create(:application_choice, :with_rejection, rejection_reason: 'Abscence of English GCSE.', application_form: application_form_three)

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          'Month' => application_form_three.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form_three.recruitment_cycle_year,
          'Sex' => application_form_three.equality_and_diversity['sex'],
          'Ethnic group' => application_form_three.equality_and_diversity['ethnic_group'],
          'Ethnic background' => application_form_three.equality_and_diversity['ethnic_background'],
          'Application status' => 'Ended without success',
          'Application choice 1 unstructured rejection reasons' => 'Abscence of English GCSE.',
          'Application choice 2 unstructured rejection reasons' => nil,
          'Application choice 3 unstructured rejection reasons' => nil,
          'Application choice 1 structured rejection reasons' => nil,
          'Application choice 2 structured rejection reasons' => nil,
          'Application choice 3 structured rejection reasons' => nil,
          'Disability 1' => application_form_three.equality_and_diversity['disabilities'].first,
          'Disability 2' => application_form_three.equality_and_diversity['disabilities'].second,
          'Disability 3' => application_form_three.equality_and_diversity['disabilities'].last,
        },
        {
          'Month' => application_form_one.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form_one.recruitment_cycle_year,
          'Sex' => application_form_one.equality_and_diversity['sex'],
          'Ethnic group' => application_form_one.equality_and_diversity['ethnic_group'],
          'Ethnic background' => application_form_one.equality_and_diversity['ethnic_background'],
          'Application status' => 'Have not started form',
          'Application choice 1 unstructured rejection reasons' => nil,
          'Application choice 2 unstructured rejection reasons' => nil,
          'Application choice 3 unstructured rejection reasons' => nil,
          'Application choice 1 structured rejection reasons' => nil,
          'Application choice 2 structured rejection reasons' => nil,
          'Application choice 3 structured rejection reasons' => nil,
          'Disability 1' => application_form_one.equality_and_diversity['disabilities'].first,
          'Disability 2' => application_form_one.equality_and_diversity['disabilities'].last,
        },
        {
          'Month' => application_form_two.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form_two.recruitment_cycle_year,
          'Sex' => application_form_two.equality_and_diversity['sex'],
          'Ethnic group' => application_form_two.equality_and_diversity['ethnic_group'],
          'Ethnic background' => application_form_two.equality_and_diversity['ethnic_background'],
          'Application status' => 'Ended without success',
          'Application choice 1 unstructured rejection reasons' => nil,
          'Application choice 2 unstructured rejection reasons' => nil,
          'Application choice 3 unstructured rejection reasons' => nil,
          'Application choice 1 structured rejection reasons' => "Something you did\nHonesty and professionalism",
          'Application choice 2 structured rejection reasons' => nil,
          'Application choice 3 structured rejection reasons' => nil,
          'Disability 1' => application_form_two.equality_and_diversity['disabilities'].first,
        },
      )
    end
  end
end
