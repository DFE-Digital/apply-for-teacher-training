require 'rails_helper'

RSpec.describe RejectApplication do
  describe '#call' do
    context 'when the rejection is valid' do
      subject(:result) do
        RejectApplication.new(
          application_choice: create(:application_choice), rejection: rejection,
        ).call
      end

      let(:rejection) do
        {
          "reason": 'Does not meet minimum requirements',
          "timestamp": '2019-03-01T15:33:49.216Z',
        }
      end

      it 'reports that it was successful' do
        expect(result.successful?).to be true
      end

      it 'returns the rejected application_choice' do
        expect(result.application_choice.status).to eq 'rejected'
        expect(result.application_choice.rejection_reason).to eq 'Does not meet minimum requirements'
        expect(result.application_choice.rejected_at).to eq '2019-03-01T15:33:49.216Z'
      end
    end
  end
end
