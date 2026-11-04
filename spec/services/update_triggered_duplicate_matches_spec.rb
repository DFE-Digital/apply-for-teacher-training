require 'rails_helper'

RSpec.describe UpdateTriggeredDuplicateMatches do
  let(:candidate1) { create(:candidate) }
  let(:candidate2) { create(:candidate) }
  let!(:application_form) do
    create(:application_form, candidate: candidate1, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
  end

  before do
    create(:application_form, candidate: candidate2, last_name: 'Thompson', date_of_birth: Date.new(1996, 1, 1), postcode: 'W6 9BH')
  end

  describe '#save!' do
    it 'creates a triggered duplicate match with both candidates' do
      described_class.new(application_form).save!

      match = TriggeredDuplicateMatch.sole
      expect(match).to have_attributes(
        last_name: 'Thompson',
        date_of_birth: Date.new(1996, 1, 1),
        postcode: 'W6 9BH',
        recruitment_cycle_year: current_year,
      )
      expect(match.candidates).to contain_exactly(candidate1, candidate2)
    end

    it 'does not create a DuplicateMatch' do
      expect { described_class.new(application_form).save! }.not_to change(DuplicateMatch, :count)
    end

    it 'does not block submission' do
      described_class.new(application_form).save!

      expect(candidate1.reload.submission_blocked).to be(false)
      expect(candidate2.reload.submission_blocked).to be(false)
    end

    it 'does not send emails' do
      expect { described_class.new(application_form).save! }.not_to have_enqueued_mail
    end

    it 'reuses an existing triggered duplicate match' do
      described_class.new(application_form).save!

      expect { described_class.new(application_form).save! }.not_to change(TriggeredDuplicateMatch, :count)
    end

    context 'when the candidate no longer matches anyone' do
      before do
        described_class.new(application_form).save!
        application_form.update!(postcode: 'SW1A 1AA')
      end

      it 'keeps the candidate in the match and touches it' do
        match = TriggeredDuplicateMatch.sole

        travel_temporarily_to(1.hour.from_now) do
          expect { described_class.new(application_form).save! }.to(change { match.reload.updated_at })
        end

        expect(candidate1.reload.triggered_duplicate_match).to eq(match)
        expect(candidate2.reload.triggered_duplicate_match).to eq(match)
      end
    end
  end
end
