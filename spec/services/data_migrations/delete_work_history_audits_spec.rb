require 'rails_helper'

RSpec.describe DataMigrations::DeleteWorkHistoryAudits do
  describe '#change' do
    it 'enques jobs to DeleteAuditsWorker' do
      create(
        :application_work_history_break_audit,
        user_type: nil,
        user_id: nil,
        created_at: DateTime.new(2024, 9, 3, 12),
        action: 'create',
        username: '(Automated process)',
      )

      expect { described_class.new.change }.to change(
        DeleteAuditsWorker.jobs, :size
      ).by(1)
    end
  end

  describe '#relation' do
    it 'returns the audits that need deleting' do
      audit_1 = create(
        :application_work_history_break_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 12),
      )
      audit_2 = create(
        :application_work_history_break_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
      )
      audit_3 = create(
        :application_experience_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
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
        user_type: nil,
        user_id: nil,
      )
      audit_6 = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
        user_type: nil,
        user_id: nil,
        created_at: DateTime.new(2024, 9, 4, 18),
      )
      audit_7 = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
        user_type: 'Provider',
      )
      audit_8 = create(
        :application_experience_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        created_at: DateTime.new(2024, 9, 4, 18),
      )
      audit_9 = create(
        :application_form_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 12),
      )

      expect(described_class.new.relation).to include(audit_1, audit_2, audit_3)
      expect(described_class.new.relation).not_to include(
        audit_4,
        audit_5,
        audit_6,
        audit_7,
        audit_8,
        audit_9,
      )
    end
  end
end
