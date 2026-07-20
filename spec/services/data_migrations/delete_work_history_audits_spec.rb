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
      work_break = create(
        :application_work_history_break_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 12),
      )
      work_break_2 = create(
        :application_work_history_break_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
      )
      work_experience = create(
        :application_experience_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
      )
      work_break_with_provider_username = create(
        :application_work_history_break_audit,
        action: 'create',
        username: 'Provider',
      )
      work_break_with_update_action = create(
        :application_work_history_break_audit,
        action: 'update',
        username: '(Automated process)',
        user_type: nil,
        user_id: nil,
      )
      work_break_outside_time_range = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
        user_type: nil,
        user_id: nil,
        created_at: DateTime.new(2024, 9, 4, 18),
      )
      work_break_with_provider_user_type = create(
        :application_work_history_break_audit,
        action: 'create',
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 18),
        user_type: 'Provider',
      )
      work_experience_outside_time_range = create(
        :application_experience_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        created_at: DateTime.new(2024, 9, 4, 18),
      )
      application_form_audit = create(
        :application_form_audit,
        action: 'create',
        user_type: nil,
        user_id: nil,
        username: '(Automated process)',
        created_at: DateTime.new(2024, 9, 3, 12),
      )

      expect(described_class.new.relation).to include(work_break, work_break_2, work_experience)
      expect(described_class.new.relation).not_to include(
        work_break_with_provider_username,
        work_break_with_update_action,
        work_break_outside_time_range,
        work_break_with_provider_user_type,
        work_experience_outside_time_range,
        application_form_audit,
      )
    end
  end
end
