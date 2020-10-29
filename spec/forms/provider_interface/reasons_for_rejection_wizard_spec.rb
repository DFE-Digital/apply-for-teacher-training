require 'rails_helper'

RSpec.describe ProviderInterface::ReasonsForRejectionWizard do
  describe '#valid_for_current_step?' do
    let(:store) { {} }
    let(:current_step) { 'initial_questions' }
    let(:wizard_params) { { current_step: current_step } }

    subject(:wizard) { described_class.new(store, wizard_params) }

    it 'validates top level questions' do
      wizard.valid_for_current_step?

      expect(wizard.errors.keys.sort).to eq(
        %i[
          candidate_behaviour_y_n
          course_full_y_n
          honesty_and_professionalism_y_n
          offered_on_another_course_y_n
          performance_at_interview_y_n
          qualifications_y_n
          quality_of_application_y_n
          safeguarding_y_n
        ],
      )
    end

    context 'when top level question is answered' do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'Yes',
          course_full_y_n: 'Yes',
          honesty_and_professionalism_y_n: 'Yes',
          offered_on_another_course_y_n: 'Yes',
          performance_at_interview_y_n: 'Yes',
          qualifications_y_n: 'Yes',
          quality_of_application_y_n: 'Yes',
          safeguarding_y_n: 'Yes',
        }
      end

      it 'validates second level options' do
        wizard.valid_for_current_step?

        expect(wizard.errors.keys.sort).to eq(
          %i[
            candidate_behaviour_what_did_the_candidate_do
            honesty_and_professionalism_concerns
            performance_at_interview_what_to_improve
            qualifications_which_qualifications
            quality_of_application_which_parts_needed_improvement
            safeguarding_concerns
          ],
        )
      end
    end

    context 'when top and second level questions are answered' do
      let(:wizard_params) do
        {
          current_step: 'initial_questions',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          course_full_y_n: 'Yes',
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns: %w[other],
          offered_on_another_course_y_n: 'Yes',
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: %w[other],
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[other],
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[other],
          safeguarding_y_n: 'Yes',
          safeguarding_concerns: %w[other],
        }
      end

      it 'validates second level options' do
        wizard.valid_for_current_step?

        expect(wizard.errors.keys.sort).to eq(
          %i[
            candidate_behaviour_other
            candidate_behaviour_what_to_improve
            honesty_and_professionalism_concerns_other_details
            qualifications_other_details
            quality_of_application_other_details
            quality_of_application_other_what_to_improve
            safeguarding_concerns_other_details
          ],
        )
      end
    end

    context 'other_reasons step' do
      let(:current_step) { 'other_reasons' }

      it 'validates top level questions' do
        wizard.valid_for_current_step?

        expect(wizard.errors.keys.sort).to eq(%i[interested_in_future_applications_y_n other_advice_or_feedback_y_n])
      end
    end

    context 'other_reasons step when top level answers are Yes' do
      let(:wizard_params) do
        {
          current_step: 'other_reasons',
          interested_in_future_applications_y_n: 'Yes',
          other_advice_or_feedback_y_n: 'Yes',
        }
      end

      it 'validates second level reasons fields' do
        wizard.valid_for_current_step?

        expect(wizard.errors.keys).to eq(%i[other_advice_or_feedback_details])
      end
    end
  end

  describe 'needs_other_reasons?' do
    it 'is true when honesty & professionalism and safeguarding answers are No' do
      expect(
        described_class.new(
          {},
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'No',
          safeguarding_y_n: 'No',
        ).needs_other_reasons?,
      ).to be true
    end

    it 'is false when either honesty & professionalism and safeguarding answers are Yes' do
      expect(
        described_class.new(
          {},
          current_step: 'initial_questions',
          honesty_and_professionalism_y_n: 'Yes',
          safeguarding_y_n: 'No',
        ).needs_other_reasons?,
      ).to be false
    end
  end
end
