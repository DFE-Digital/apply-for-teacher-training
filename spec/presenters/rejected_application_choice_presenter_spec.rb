require 'rails_helper'

RSpec.describe RejectedApplicationChoicePresenter do
  describe '#rejection_reasons' do
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there is a rejection_reason set' do
      it 'returns that reason only' do
        application_choice.rejection_reason = 'There was something wrong with your application'

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Why your application was unsuccessful' => ['There was something wrong with your application'] },
        )
      end
    end

    describe 'when there are no rejection reasons' do
      let(:reasons_for_rejection) { {} }

      it 'returns an empty hash' do
        application_choice.structured_rejection_reasons = reasons_for_rejection

        expect(rejected_application_choice.rejection_reasons).to eq({})
      end
    end

    describe 'candidate behaviour' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Something you did' => ['Bad language',
                                    'Do not swear'] },
        )
      end
    end

    describe 'quality of application' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
          quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
          quality_of_application_subject_knowledge_what_to_improve: 'Write in the first person',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)
        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Quality of application' => ['Do not refer to yourself in the third person',
                                         'Write in the first person'] },
        )
      end
    end

    describe 'qualifications' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_english_gcse no_science_gcse no_degree],
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Qualifications' => ['No English GCSE grade 4 (C) or above, or valid equivalent',
                                 'No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)',
                                 'No degree'] },
        )
      end
    end

    describe 'performance' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'There was no need to do all those pressups',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Performance at interview' => ['There was no need to do all those pressups'] },
        )
      end
    end

    describe 'other reasons' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          course_full_y_n: 'Yes',
          offered_on_another_course_y_n: 'Yes',
          offered_on_another_course_details: 'You have already been offered the Math course',
          cannot_sponsor_visa_y_n: 'Yes',
          cannot_sponsor_visa_details: 'You misspelled visa as viza',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Course full' => ['The course you applied to is full'],
            'They offered you a place on another course' => ['You have already been offered the Math course'],
            'Visa application sponsorship' => ['You misspelled visa as viza'] },
        )
      end
    end

    describe 'honesty_and_professionalism' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'The year you graduated can not be in the future',
          honesty_and_professionalism_concerns_references_details: 'The reference email you provided does not exist',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Honesty and professionalism' => ['The year you graduated can not be in the future',
                                              'The reference email you provided does not exist'] },
        )
      end
    end

    describe 'safeguarding_issues' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          safeguarding_y_n: 'Yes',
          safeguarding_concerns_other_details: 'Other safeguarding details',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Safeguarding issues' => ['Other safeguarding details'] },
        )
      end
    end

    describe 'other_advice_or_feedback' do
      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          other_advice_or_feedback_y_n: 'Yes',
          other_advice_or_feedback_details: 'That zoom background...',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Additional advice' => ['That zoom background...'] },
        )
      end
    end

    describe 'interested_in_future_applications' do
      let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }
      let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, provider: provider)) }
      let(:provider) { build_stubbed(:provider, name: 'UoG') }

      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          interested_in_future_applications_y_n: 'Yes',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Future applications' => ['UoG would be interested in future applications from you.'] },
        )
      end
    end
  end
end
