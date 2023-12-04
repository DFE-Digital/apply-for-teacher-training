require 'rails_helper'

RSpec.describe DataMigrations::UpdateDeclineByDefaultAtFromCurrentCycle do
  let(:application_form) do
    create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year: recruitment_cycle_year,
    )
  end

  let!(:application_choice) do
    create(
      :application_choice,
      application_form:,
      decline_by_default_at:,
      decline_by_default_days: 10,
    )
  end

  context 'when 2023 recruitment cycle' do
    let!(:recruitment_cycle_year) { 2023 }
    let!(:decline_by_default_at) { CycleTimetable.find_opens(recruitment_cycle_year) }

    it 'does not update records' do
      expect { described_class.new.change }.not_to(change { application_choice.reload.decline_by_default_at })
    end
  end

  context 'when 2024 recruitment cycle' do
    let!(:recruitment_cycle_year) { 2024 }

    context 'when application does not have a decline_by_default_at' do
      let!(:decline_by_default_at) { nil }

      it 'does not update records' do
        expect { described_class.new.change }.not_to(change { application_choice.reload.decline_by_default_at })
      end
    end

    context 'when application has a decline_by_default_at set to apply deadline' do
      let!(:decline_by_default_at) { CycleTimetable.apply_1_deadline(recruitment_cycle_year) }

      it 'does not update records' do
        expect { described_class.new.change }.not_to(change { application_choice.reload.decline_by_default_at })
      end
    end

    context 'when application has a decline_by_default_at set to before apply deadline' do
      let!(:decline_by_default_at) { CycleTimetable.apply_1_deadline(recruitment_cycle_year) - 1.day }

      it 'updates the records' do
        expect { described_class.new.change }.to(
          change { application_choice.reload.decline_by_default_at }
            .from(CycleTimetable.apply_1_deadline(recruitment_cycle_year) - 1.day)
            .to(CycleTimetable.apply_1_deadline(recruitment_cycle_year)),
        )
      end
    end
  end
end
