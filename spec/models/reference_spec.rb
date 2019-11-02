require 'rails_helper'

RSpec.describe Reference, type: :model do
  subject { create(:reference) }

  describe 'a valid reference' do
    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
  end
end
