require 'rails_helper'

RSpec.describe VendorAPIToken, type: :model do
  it 'generates a hashed token that can be used' do
    unhashed_token = described_class.create_with_random_token!(provider: create(:provider))

    expect(
      described_class.find_by_unhashed_token(unhashed_token),
    ).to eql(described_class.last)
  end
end
