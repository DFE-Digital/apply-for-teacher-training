require 'rails_helper'

RSpec.describe AccountRecoveryRequestCode do
  describe 'associations' do
    it { is_expected.to belong_to(:account_recovery_request) }
  end
end
