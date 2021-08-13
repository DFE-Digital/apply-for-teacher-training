require 'rails_helper'

RSpec.describe CreateExampleProviderUsersWithPermissions do
  it 'creates users' do
    %w[1JA 24J 24P D39 S72 1JB 4T7 1N1].each do |code|
      create(:provider, code: code)
    end

    expect {
      described_class.call
    }.to(change { ProviderUser.count })
  end
end
