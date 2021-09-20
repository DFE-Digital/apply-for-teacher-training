require 'rails_helper'

RSpec.describe UpdateFraudMatches do
  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }

  before do
    Timecop.freeze(Time.zone.local(2020, 8, 23, 12, 0o0, 0o0)) do
      create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
      create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    end
  end

  describe '#save!' do
    it 'creates a fraud match with associated candidates for new match' do
      described_class.new.save!

      match = FraudMatch.first

      expect(match.postcode).to eq('W6 9BH')
      expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
      expect(match.last_name).to eq('Thompson')
      expect(match.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
      expect(match.candidates.first).to eq(candidate1)
      expect(match.candidates.second).to eq(candidate2)
    end

    it 'updates an existing fraud match with new candidate' do
      described_class.new.save!

      match = FraudMatch.first
      expect(match.candidates.third).to eq(nil)

      create(:application_form, candidate: create(:candidate, email_address: 'exemplar3@example.com'), first_name: 'Jaffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
      described_class.new.save!

      match = FraudMatch.first

      expect(match.candidates.third.email_address).to eq('exemplar3@example.com')

      expect(match.postcode).to eq('W6 9BH')
      expect(match.date_of_birth).to eq(candidate1.application_forms.first.date_of_birth)
      expect(match.last_name).to eq('Thompson')
      expect(match.recruitment_cycle_year).to eq(RecruitmentCycle.current_year)
    end
  end
end
