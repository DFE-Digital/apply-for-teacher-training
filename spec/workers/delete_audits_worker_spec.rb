require 'rails_helper'

RSpec.describe DeleteAuditsWorker do
  describe '#perform' do
    it 'deletes audits by id' do
      audit_1 = create(:application_work_history_break_audit)
      audit_2 = create(:application_work_history_break_audit)
      audit_3 = create(:application_work_history_break_audit)
      audit_ids = [audit_1.id, audit_2.id]

      described_class.new.perform(audit_ids)

      expect(Audited::Audit.where(id: audit_ids)).not_to exist
      expect(Audited::Audit.where(id: audit_3.id)).to exist
    end
  end
end
