require 'rails_helper'

RSpec.describe ConfirmEnrolment do
  describe '#call' do
    context 'when the update is valid' do
      subject(:result) do
        ConfirmEnrolment.new(
          application_choice: create(:application_choice, status: 'recruited'),
        ).call
      end

      it 'reports that it was successful' do
        expect(result.successful?).to be true
      end

      it 'returns the updated application_choice' do
        expect(result.application_choice.status).to eq 'enrolled'
      end
    end
  end
end
