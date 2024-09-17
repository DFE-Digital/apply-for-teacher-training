require 'rails_helper'

RSpec.describe DeleteWorkHistoryAuditsWorker do
  describe '#perform' do
    it 'deletes work history audits associated to an application_choice' do
      audit_1 = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
      )
      audit_2 = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
      )
      audit_3 = create(
        :application_experience_audit,
        action: 'create',
        username: '(Automated process)',
      )
      audit_4 = create(
        :application_work_history_break_audit,
        action: 'create',
        username: 'Provider',
      )
      audit_5 = create(
        :application_work_history_break_audit,
        action: 'update',
        username: '(Automated process)',
      )
      audit_ids = [audit_1.id, audit_2.id, audit_3.id, audit_4.id, audit_5.id]

      described_class.new.perform(audit_ids)

      expect(Audited::Audit.where(id: audit_1.id)).not_to exist
      expect(Audited::Audit.where(id: audit_2.id)).not_to exist
      expect(Audited::Audit.where(id: audit_3.id)).not_to exist
      expect(Audited::Audit.where(id: audit_4.id)).to exist
      expect(Audited::Audit.where(id: audit_5.id)).to exist
    end
  end
end
