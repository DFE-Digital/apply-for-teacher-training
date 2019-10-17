require 'rails_helper'

RSpec.describe VendorApiToken, type: :model do
  it 'generates a hashed token that can be used' do
    unhashed_token = VendorApiToken.create_with_random_token!(provider: create(:provider))

    expect(
      VendorApiToken.find_by_unhashed_token(unhashed_token),
    ).to eql(VendorApiToken.last)
  end
end
