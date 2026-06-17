require 'rails_helper'

RSpec.describe SupportInterface::WhoRanWhichExportExport do
  describe 'documentation' do
    before do
      support_user = create(:support_user)
      create(:data_export, initiator: support_user)
    end

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes containing generated data exports and who initiated them ordered by type and created_at' do
      support_user1 = create(:support_user)
      support_user2 = create(:support_user)
      latest_provider_user_export = create(:data_export, initiator: support_user2)
      earliest_provider_user_export = create(:data_export, initiator: support_user1, created_at: 3.days.ago)
      user_permissions_export = create(:data_export, initiator: support_user1, created_at: 1.day.ago, export_type: 'active_provider_user_permissions', name: 'Active provider user permissions')
      active_provider_users_export = create(:data_export, initiator: nil, export_type: 'active_provider_users', name: 'Active users affiliated with a Provider')

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          export_type: earliest_provider_user_export.export_type,
          created_at: earliest_provider_user_export.created_at,
          initiated_by: support_user1.email_address,
        },
        {
          export_type: latest_provider_user_export.export_type,
          created_at: latest_provider_user_export.created_at,
          initiated_by: support_user2.email_address,
        },
        {
          export_type: user_permissions_export.export_type,
          created_at: user_permissions_export.created_at,
          initiated_by: support_user1.email_address,
        },
        {
          export_type: active_provider_users_export.export_type,
          created_at: active_provider_users_export.created_at,
          initiated_by: nil,
        },
      )
    end
  end
end
