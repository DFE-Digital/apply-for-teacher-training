require 'rails_helper'

RSpec.describe AccountRecoveryRequest do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to have_many(:codes).class_name('AccountRecoveryRequestCode').dependent(:destroy) }
  end

  it { is_expected.to normalize(:previous_account_email_address).from(" ME@XYZ.COM\n").to('me@xyz.com') }
end
