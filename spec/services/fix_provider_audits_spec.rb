require 'rails_helper'

RSpec.describe FixProviderAudits do
  it 'updates a legacy provider audit entry when there is a matching provider user' do
    provider_user = create :provider_user, email_address: 'bob@example.com'
    audit = Audited::Audit.create(
      username: 'bob@example.com (Provider)',
    )
    described_class.new.call
    expect(audit.reload.user_id).to eq provider_user.id
    expect(audit.user_type).to eq 'ProviderUser'
    expect(audit.username).to be_nil
  end

  it 'does nothing to a legacy provider audit entry that does not match provider user' do
    audit = Audited::Audit.create(
      username: 'bob@example.com (Provider)',
    )
    described_class.new.call
    expect(audit.reload.user_id).to be_nil
    expect(audit.user_type).to be_nil
    expect(audit.username).to eq 'bob@example.com (Provider)'
  end

  it 'does nothing to a non legacy provider audit entry' do
    support_user = create :support_user, email_address: 'ted@example.com'
    audit = Audited::Audit.create(
      user: support_user,
      username: nil,
    )
    described_class.new.call
    expect(audit.reload.user_id).to eq support_user.id
    expect(audit.user_type).to eq 'SupportUser'
    expect(audit.username).to be_nil
  end
end
