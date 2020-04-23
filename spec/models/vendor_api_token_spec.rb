require 'rails_helper'

RSpec.describe VendorAPIToken, type: :model do
  it 'generates a hashed token that can be used' do
    unhashed_token = VendorAPIToken.create_with_random_token!(provider: create(:provider))

    expect(
      VendorAPIToken.find_by_unhashed_token(unhashed_token),
    ).to eql(VendorAPIToken.last)
  end
end
