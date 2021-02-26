require 'rails_helper'

RSpec.describe SupportInterface::UserPermissionsExport do
  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user) }
  let(:audit_user) { create(:provider_user) }
  let(:provider_permissions) { create(:provider_permissions, provider: provider, provider_user: provider_user) }
  let(:audit_entry) { create(:provider_permissions_audit, provider_permissions: provider_permissions, changes: changes, user: audit_user) }
  let(:changes) do
    {
      'make_decisions' => [false, true],
      'manage_organisations' => [true, false],
      'manage_users' => true,
      'view_diversity_information' => [true, false],
      'view_safeguarding_information' => false,
    }
  end

  describe '#data_for_export' do
    it 'exports permissions changes' do
      audit_user_provider = create(:provider)
      audit_user.providers << audit_user_provider
      audit_entry

      exported_data = described_class.new.data_for_export
      created_at, user_id, username, provider_code, provider_name,
        provider_user_name, enabled, disabled = exported_data.first.values

      expect(created_at.to_s).to eq(audit_entry.created_at.to_s)
      expect(user_id).to eq(audit_user.id)
      expect(username).to eq(audit_user.full_name)
      expect(provider_code).to eq(audit_user_provider.code)
      expect(provider_name).to eq(audit_user_provider.name)
      expect(provider_user_name).to eq(provider_user.full_name)
      expect(enabled).to eq('make_decisions, manage_users')
      expect(disabled).to eq('manage_organisations, view_diversity_information, view_safeguarding_information')
    end

    context 'for audit entries made by support users' do
      let(:audit_user) { create(:support_user) }

      it 'omits provider information' do
        audit_entry

        exported_data = described_class.new.data_for_export
        created_at, user_id, username, provider_code, provider_name,
          provider_user_name, enabled, disabled = exported_data.first.values

        expect(created_at.to_s).to eq(audit_entry.created_at.to_s)
        expect(user_id).to eq(audit_user.id)
        expect(username).to eq("#{audit_user.first_name} #{audit_user.last_name}")
        expect(provider_code).to be_nil
        expect(provider_name).to be_nil
        expect(provider_user_name).to eq(provider_user.full_name)
        expect(enabled).to eq('make_decisions, manage_users')
        expect(disabled).to eq('manage_organisations, view_diversity_information, view_safeguarding_information')
      end
    end
  end
end
