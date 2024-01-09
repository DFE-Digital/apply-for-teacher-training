require 'rails_helper'

RSpec.describe RejectionReasons::ReasonsForRejectionPresenter do
  describe '#rejection_reasons' do
    let(:reasons) { {} }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: reasons,
        rejection_reasons_type: 'reasons_for_rejection',
      )
    end

    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there are no rejection reasons' do
      it 'returns an empty hash' do
        expect(rejected_application_choice.rejection_reasons).to eq({})
      end
    end

    describe 'candidate behaviour' do
      let(:reasons) do
        {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Something you did' => ['Bad language',
                                    'Do not swear'] },
        )
      end
    end

    describe 'quality of application' do
      let(:reasons) do
        {
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
          quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
          quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Quality of application' => ['Do not refer to yourself in the third person',
                                         'Write in the first person'] },
        )
      end
    end

    describe 'qualifications' do
      let(:reasons) do
        {
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_english_gcse no_science_gcse no_degree],
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Qualifications' => ['No English GCSE grade 4 (C) or above, or valid equivalent',
                                 'No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)',
                                 'No degree'] },
        )
      end
    end

    describe 'performance' do
      let(:reasons) do
        {
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'There was no need to do all those pressups',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Performance at interview' => ['There was no need to do all those pressups'] },
        )
      end
    end

    describe 'other reasons' do
      let(:reasons) do
        {
          course_full_y_n: 'Yes',
          offered_on_another_course_y_n: 'Yes',
          offered_on_another_course_details: 'You have already been offered the Math course',
          cannot_sponsor_visa_y_n: 'Yes',
          cannot_sponsor_visa_details: 'You misspelled visa as viza',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Course full' => ['The course you applied to is full'],
            'They offered you a place on another course' => ['You have already been offered the Math course'],
            'Visa application sponsorship' => ['You misspelled visa as viza'] },
        )
      end
    end

    describe 'honesty_and_professionalism' do
      let(:reasons) do
        {
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'The year you graduated can not be in the future',
          honesty_and_professionalism_concerns_references_details: 'The reference email you provided does not exist',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Honesty and professionalism' => ['The year you graduated can not be in the future',
                                              'The reference email you provided does not exist'] },
        )
      end
    end

    describe 'safeguarding_issues' do
      let(:reasons) do
        {
          safeguarding_y_n: 'Yes',
          safeguarding_concerns_other_details: 'Other safeguarding details',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Safeguarding issues' => ['Other safeguarding details'] },
        )
      end
    end

    describe 'other_advice_or_feedback' do
      let(:reasons) do
        {
          other_advice_or_feedback_y_n: 'Yes',
          other_advice_or_feedback_details: 'That zoom background...',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Additional advice' => ['That zoom background...'] },
        )
      end
    end

    describe 'why_are_you_rejecting_this_application' do
      let(:reasons) do
        {
          why_are_you_rejecting_this_application: 'That zoom background...',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Reasons why your application was unsuccessful' => ['That zoom background...'] },
        )
      end
    end

    describe 'interested_in_future_applications' do
      let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, provider:)) }
      let(:provider) { build_stubbed(:provider, name: 'UoG') }

      let(:reasons) do
        {
          interested_in_future_applications_y_n: 'Yes',
        }
      end

      it 'returns a hash with the relevant title and reasons' do
        application_choice.course_option = course_option
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Future applications' => ['UoG would be interested in future applications from you.'] },
        )
      end
    end
  end
end
