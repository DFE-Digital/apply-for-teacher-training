require 'rails_helper'

RSpec.describe WithdrawalRequest do
  describe 'associations' do
    it { is_expected.to belong_to(:application_choice) }
    it { is_expected.to belong_to(:provider_user) }
  end
end
