require 'rails_helper'

RSpec.describe DataMigrations::BackfillSetupInterviewsPermission do
  let!(:provider_permissions) { create(:provider_permissions, make_decisions: true, set_up_interviews: false) }

  it 'sets the setup_interviews permission to true' do
    described_class.new.change
    expect(provider_permissions.reload.set_up_interviews).to be(true)
  end

  it 'does not update the application_choice timestamps' do
    provider_permissions_created_at = provider_permissions.created_at
    provider_permissions_updated_at = provider_permissions.updated_at

    described_class.new.change

    expect(provider_permissions.created_at).to eq(provider_permissions_created_at)
    expect(provider_permissions.updated_at).to eq(provider_permissions_updated_at)
  end

  it 'does not update the audit log', with_audited: true do
    provider_permissions_created_at = provider_permissions.created_at
    provider_permissions_updated_at = provider_permissions.updated_at

    expect { described_class.new.change }.not_to(change { Audited::Audit.count })

    expect(provider_permissions.created_at).to eq(provider_permissions_created_at)
    expect(provider_permissions.updated_at).to eq(provider_permissions_updated_at)
  end
end
