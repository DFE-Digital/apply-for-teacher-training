require 'rails_helper'

RSpec.describe AccountRecoveryRequest do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to have_many(:account_recovery_request_codes).dependent(:destroy) }
  end
end
