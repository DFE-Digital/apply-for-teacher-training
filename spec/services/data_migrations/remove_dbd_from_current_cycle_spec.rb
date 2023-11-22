require 'rails_helper'

RSpec.describe DataMigrations::RemoveDbdFromCurrentCycle do
  context 'when application is declined by default' do
    context 'when 2023 recruitment cycle' do
      let!(:application_choice) do
        create(
          :application_choice,
          :declined_by_default,
          current_recruitment_cycle_year: 2023,
        )
      end

      it 'does not update records' do
        expect { described_class.new.change }.not_to(change { application_choice })
      end
    end

    context 'when 2024 recruitment cycle' do
      let!(:application_choice) do
        create(
          :application_choice,
          :declined_by_default,
          current_recruitment_cycle_year: 2024,
        )
      end

      it 'updates records and set to offer made' do
        described_class.new.change
        application_choice.reload
        expect(application_choice.status).to eq('offer')
        expect(application_choice.declined_by_default).to be(false)
        expect(application_choice.decline_by_default_days).to be_nil
        expect(application_choice.declined_at).to be_nil
      end
    end
  end

  context 'when application is declined but not by default' do
    let!(:application_choice) do
      create(
        :application_choice,
        :declined,
        declined_by_default: false,
        current_recruitment_cycle_year: 2024,
      )
    end

    it 'does not update records' do
      expect { described_class.new.change }.not_to(change { application_choice })
    end
  end
end
