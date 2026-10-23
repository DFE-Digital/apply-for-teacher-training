require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::OptIn, type: :model do
  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(pool_status: nil, opt_out_reason: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:pool_status) }

    context 'when the pool status is opt_out, and the opt out reason is more that 200 words' do
      it 'is invalid' do
        step = described_class.new(pool_status: 'opt_out', opt_out_reason: 'a ' * 201)
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to include('Opt out reason Reason for not sharing your application details must be 200 words or less')
      end
    end
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:pool_status, :opt_out_reason)
    end
  end
end
