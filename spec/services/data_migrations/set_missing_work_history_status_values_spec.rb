require 'rails_helper'

RSpec.describe DataMigrations::SetMissingWorkHistoryStatusValues do
  let(:application_form) do
    create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year:,
      work_history_status:,
      work_history_completed:,
    )
  end

  context 'when 2023 recruitment cycle, work history status is nil and work history is complete' do
    let(:recruitment_cycle_year) { 2023 }
    let(:work_history_status) { nil }
    let(:work_history_completed) { true }

    it 'does not update the application form' do
      expect { described_class.new.change }.not_to(change { application_form.reload.work_history_status })
    end
  end

  context 'when 2024 recruitment cycle' do
    let(:recruitment_cycle_year) { 2024 }

    context 'when work history status is not nil' do
      let(:work_history_status) { 'can_not_complete' }

      context 'when work history is not complete' do
        let(:work_history_completed) { false }

        it 'does not update the application form' do
          expect { described_class.new.change }.not_to(change { application_form.reload.work_history_status })
        end
      end

      context 'when work history is complete' do
        let(:work_history_completed) { true }

        it 'does not update the application form' do
          expect { described_class.new.change }.not_to(change { application_form.reload.work_history_status })
        end
      end
    end

    context 'when work history status is nil' do
      let(:work_history_status) { nil }

      context 'when work history is not complete' do
        let(:work_history_completed) { false }

        it 'does not update the application form' do
          expect { described_class.new.change }.not_to(change { application_form.reload.work_history_status })
        end
      end

      context 'when work history is complete' do
        let(:work_history_completed) { true }

        it 'updates the application forms' do
          expect { described_class.new.change }.to(
            change { application_form.reload.work_history_status }
              .from(nil)
              .to('can_complete'),
          )
        end
      end
    end
  end
end
