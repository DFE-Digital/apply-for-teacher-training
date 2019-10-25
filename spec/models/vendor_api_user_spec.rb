require 'rails_helper'

RSpec.describe VendorApiUser, type: :model do
  subject { create(:vendor_api_user) }

  describe 'a valid vendor API user' do
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_presence_of :user_id }
    it { is_expected.to belong_to :vendor_api_token }
  end
end
