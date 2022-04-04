require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonPresenter do
  describe '#rejection_reasons' do
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there is a rejection_reason set' do
      it 'returns that reason only' do
        application_choice.rejection_reason = 'There was something wrong with your application'
        application_choice.rejection_reasons_type = 'rejection_reason'

        expect(rejected_application_choice.rejection_reasons).to eq(
          { 'Why your application was unsuccessful' => ['There was something wrong with your application'] },
        )
      end
    end
  end
end
