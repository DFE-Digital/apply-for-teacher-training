require 'rails_helper'

RSpec.describe CreateSupportUser do
  it 'creates a new SupportUser' do
    expect { described_class.new(dfe_sign_in_uid: 'ABC', email_address: 'bob@example.com').call }.to change { SupportUser.count }.by(1)
    new_support_user = SupportUser.last
    expect(new_support_user.dfe_sign_in_uid).to eq 'ABC'
    expect(new_support_user.email_address).to eq 'bob@example.com'
  end

  it 'returns an existing SupportUser if it already exists and updates it\'s email_address' do
    support_user = create :support_user
    result = nil
    expect { result = described_class.new(dfe_sign_in_uid: support_user.dfe_sign_in_uid, email_address: 'bob@support.com').call }.not_to(change { SupportUser.count })
    expect(result).to eq support_user
    expect(result.email_address).to eq 'bob@support.com'
  end
end
