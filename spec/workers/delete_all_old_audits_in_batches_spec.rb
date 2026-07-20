require 'rails_helper'

RSpec.describe DeleteAllOldAuditsInBatches do
  describe '#perform' do
    it 'destroys all old audit records' do
      # An audit is created on startup with `auditable_type: "SiteSetting"`
      destroyable_audit_1 = create(:audit, created_at: Time.zone.local(2020, 10, 3))
      destroyable_audit_2 = create(:audit, created_at: Time.zone.local(2020, 10, 3))
      destroyable_audit_3 = create(:audit, created_at: Time.zone.local(2021, 10, 3))
      destroyable_audit_4 = create(:audit, created_at: Time.zone.local(2022, 10, 3))
      destroyable_audit_5 = create(:audit, created_at: Time.zone.local(2022, 10, 3, 23, 59, 59)) # 1 second before the timestamp
      safe_audit = create(:audit, created_at: Time.zone.local(2022, 10, 4, 0, 0, 1)) # 1 second after the timestamp

      described_class.perform_sync

      expect(Audited::Audit.all).to include(safe_audit)
      expect(Audited::Audit.all).not_to include(
        destroyable_audit_1,
        destroyable_audit_2,
        destroyable_audit_3,
        destroyable_audit_4,
        destroyable_audit_5,
      )
    end
  end
end
