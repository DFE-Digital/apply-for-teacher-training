require 'rails_helper'

RSpec.describe DataMigrations::ResolveDuplicateMatchesFrom2024AndEarlier do
  describe '#change' do
    let(:end_of_2024_cycle) { Date.new(2024, 9, 30) }

    it 'resolves an unresolved duplicate match when all application forms were last updated before the end of the 2024 cycle' do
      duplicate_match = create(:duplicate_match, resolved: false)

      candidate = create(:candidate, fraud_match_id: duplicate_match.id)
      create(
        :application_form,
        candidate:,
        updated_at: end_of_2024_cycle - 1.day,
      )

      expect { described_class.new.change }.to change { duplicate_match.reload.resolved }.from(false).to(true)
    end

    it 'does not resolve an unresolved duplicate match when an application form was updated after the cutoff date' do
      duplicate_match = create(:duplicate_match, resolved: false)

      candidate = create(:candidate, fraud_match_id: duplicate_match.id)
      create(
        :application_form,
        candidate:,
        updated_at: end_of_2024_cycle + 1.day,
      )

      expect { described_class.new.change }.not_to(change { duplicate_match.reload.resolved })
    end

    it 'does not resolve a duplicate match when one application form is newer than the cutoff date' do
      duplicate_match = create(:duplicate_match, resolved: false)

      old_candidate = create(:candidate, fraud_match_id: duplicate_match.id)
      recent_candidate = create(:candidate, fraud_match_id: duplicate_match.id)

      create(
        :application_form,
        candidate: old_candidate,
        updated_at: end_of_2024_cycle - 1.day,
      )

      create(
        :application_form,
        candidate: recent_candidate,
        updated_at: end_of_2024_cycle + 1.day,
      )

      expect { described_class.new.change }.not_to(change { duplicate_match.reload.resolved })
    end
  end
end
