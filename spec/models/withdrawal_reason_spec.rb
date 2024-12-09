require 'rails_helper'

RSpec.describe WithdrawalReason do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:reason) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:application_choice) }
  end
end
