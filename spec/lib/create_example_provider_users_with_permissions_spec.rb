require 'rails_helper'

RSpec.describe CreateExampleProviderUsersWithPermissions do
  it 'creates users' do
    %w[U80 24J 24P D39 S72 1JB 1ZW 1N1].each do |code|
      create(:provider, code:)
    end

    expect {
      described_class.call
    }.to(change { ProviderUser.count })
  end
end
