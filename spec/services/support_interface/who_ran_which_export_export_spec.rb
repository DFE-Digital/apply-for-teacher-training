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
    it 'returns an array of hashes constaining generated data exports and who initiated them ordered by type and created_at' do
      support_user1 = create(:support_user)
      support_user2 = create(:support_user)
      latest_provider_user_export = create(:data_export, initiator: support_user2)
      earliest_provider_user_export = create(:data_export, initiator: support_user1, created_at: 3.days.ago)
      work_history_export = create(:data_export, initiator: support_user1, created_at: 1.day.ago, export_type: 'work_history_break', name: 'Work history break')

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
          export_type: work_history_export.export_type,
          created_at: work_history_export.created_at,
          initiated_by: support_user1.email_address,
        },
      )
    end
  end
end
