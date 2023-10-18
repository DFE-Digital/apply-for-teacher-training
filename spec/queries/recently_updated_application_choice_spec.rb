require 'rails_helper'

RSpec.describe RecentlyUpdatedApplicationChoice, :with_audited do
  subject(:service) { described_class.new(application_choice:).call }

  describe '#call' do
    let(:application_choice) do
      create(:application_choice, {
        created_at: 7.months.ago,
        sent_to_provider_at:,
        updated_at: edited_at + 1.second,
      })
    end
    let(:sent_to_provider_at) { 6.months.ago }

    before do
      create(:application_form_audit, {
        created_at: edited_at,
        application_choice: application_choice,
        changes: { 'date_of_birth' => %w[01-01-2000 02-01-2000] },
      })
    end

    context 'update_at is before than UPDATED_RECENTLY_DAYS days ago' do
      let(:edited_at) { described_class::UPDATED_RECENTLY_DAYS.days.ago + 1 }

      it 'is not recently updated' do
        expect(service).to be(true)
      end
    end

    context 'update_at is after than UPDATED_RECENTLY_DAYS days ago' do
      let(:edited_at) { described_class::UPDATED_RECENTLY_DAYS.days.ago - 1 }

      it 'is recently updated' do
        expect(service).to be(false)
      end
    end

    context 'false unless sent_to_provider_at' do
      let(:edited_at) { described_class::UPDATED_RECENTLY_DAYS.days.ago + 1 }
      let(:sent_to_provider_at) { nil }

      it 'is not recently updated' do
        expect(service).to be(false)
      end
    end

    context 'when update is before sent_to_provider_at' do
      let(:edited_at) { described_class::UPDATED_RECENTLY_DAYS.days.ago - 2 }
      let(:sent_to_provider_at) { described_class::UPDATED_RECENTLY_DAYS.days.ago - 1 }

      it 'is not recently updated' do
        expect(service).to be(false)
      end
    end
  end
end
