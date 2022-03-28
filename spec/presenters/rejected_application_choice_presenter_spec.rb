require 'rails_helper'

RSpec.describe RejectedApplicationChoicePresenter do
  describe '#rejection_reasons' do
    let(:application_choice) { build_stubbed(:application_choice, status: :rejected, rejected_at: Time.zone.now) }
    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'for a rejected application with no rejection reasons' do
      it 'is nil' do
        expect(rejected_application_choice.rejection_reasons).to be_nil
      end
    end

    describe 'for a single rejection_reason' do
      it 'returns that reason only' do
        application_choice.rejection_reason = 'There was something wrong with your application'
        application_choice.rejection_reasons_type = 'rejection_reason'

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Why your application was unsuccessful' => ['There was something wrong with your application'] },
        )
      end
    end

    describe 'when there are no rejection reasons' do
      let(:reasons_for_rejection) { {} }

      it 'returns an empty hash' do
        application_choice.structured_rejection_reasons = reasons_for_rejection
        application_choice.rejection_reasons_type = 'reasons_for_rejection'

        expect(rejected_application_choice.rejection_reasons).to eq({})
      end
    end

    describe 'when ApplicationChoice#rejection_reasons_type is reasons_for_rejection' do
      it 'calls RejectionReasons::ReasonsForRejectionPresenter' do
        application_choice.rejection_reasons_type = 'reasons_for_rejection'

        expect(described_class.new(application_choice).presenter).to be_a(RejectionReasons::ReasonsForRejectionPresenter)
      end

      it 'returns a hash with the relevant title and reasons' do
        reasons_for_rejection = {
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_what_did_the_candidate_do: %w[other],
          candidate_behaviour_other: 'Bad language',
          candidate_behaviour_what_to_improve: 'Do not swear',
        }
        application_choice.structured_rejection_reasons = reasons_for_rejection
        application_choice.rejection_reasons_type = 'reasons_for_rejection'
        rejected_application_choice = described_class.new(application_choice)

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Something you did' => ['Bad language',
                                    'Do not swear'] },
        )
      end
    end

    describe 'when ApplicationChoice#rejection_reasons_type is rejection_reasons' do
      it 'calls RejectionReasons::ReasonsForRejectionPresenter' do
        application_choice.rejection_reasons_type = 'rejection_reasons'

        expect(described_class.new(application_choice).presenter).to be_a(RejectionReasons::RejectionReasonsPresenter)
      end

      it 'returns a hash with the relevant title and reasons for redesigned rejection reasons' do
        application_choice.rejection_reasons_type = 'rejection_reasons'
        application_choice.structured_rejection_reasons = {
          selected_reasons: [
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Some text?' } },
          ],
        }
        expect(rejected_application_choice.rejection_reasons).to eq({ 'Other' => ['Some text?'] })
      end
    end
  end
end
