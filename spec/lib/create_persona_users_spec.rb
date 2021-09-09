require 'rails_helper'

RSpec.describe CreatePersonaUsers do
  before do
    %w[1JA 1JB 24J 1N1 W53].each do |code|
      create(:provider, code: code)
    end
  end

  it 'creates users' do
    expect {
      described_class.call
    }.to(change { ProviderUser.count }.by(6))
  end
end
