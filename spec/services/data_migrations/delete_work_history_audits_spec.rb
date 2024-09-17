require 'rails_helper'

RSpec.describe DataMigrations::DeleteWorkHistoryAudits do
  describe '#change' do
    it 'enques jobs to DeleteWorkHistoryAuditsWorker' do
      create(
        :application_work_history_break_audit,
        created_at: DateTime.new(2024, 9, 3, 12),
        user_type: nil,
        user_id: nil,
      )

      expect { described_class.new.change }.to change(
        DeleteWorkHistoryAuditsWorker.jobs, :size
      ).by(1)
    end
  end

  describe '#relation' do
    it 'returns the audits that need deleting' do
      audit_1 = create(
        :application_work_history_break_audit,
        created_at: DateTime.new(2024, 9, 3, 12),
        user_type: nil,
        user_id: nil,
      )
      audit_2 = create(
        :application_work_history_break_audit,
        created_at: DateTime.new(2024, 9, 3, 18),
        user_type: nil,
        user_id: nil,
      )
      audit_3 = create(:application_work_history_break_audit)
      audit_4 = create(
        :application_work_history_break_audit,
        created_at: DateTime.new(2024, 9, 3, 12),
      )

      expect(described_class.new.relation).to include(audit_1, audit_2)
      expect(described_class.new.relation).not_to include(audit_3, audit_4)
    end
  end
end
