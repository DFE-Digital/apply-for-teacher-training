require 'rails_helper'

RSpec.describe ProviderUser, type: :model do
  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      provider_user = create :provider_user, email_address: 'Bob.Roberts@example.com'
      expect(provider_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end
end
