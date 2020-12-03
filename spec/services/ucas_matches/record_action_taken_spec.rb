require 'rails_helper'

RSpec.describe UCASMatches::RecordActionTaken, sidekiq: true do
  let!(:ucas_match) { create(:ucas_match, matching_state: 'new_match', action_taken: nil) }

  describe '#call' do
    it 'records the action taken when given a string' do
      described_class.new(ucas_match, 'initial_emails_sent').call
      ucas_match.reload

      expect(ucas_match.action_taken).to eq('initial_emails_sent')
    end

    it 'records the action taken when given a symbol' do
      described_class.new(ucas_match, :initial_emails_sent).call
      ucas_match.reload

      expect(ucas_match.action_taken).to eq('initial_emails_sent')
    end

    it 'records the time of the action' do
      described_class.new(ucas_match, 'initial_emails_sent').call
      ucas_match.reload

      expect(ucas_match.candidate_last_contacted_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'does not record an invalid action' do
      expect {
        described_class.new(ucas_match, 'had_an_ice_cream').call
      }.to raise_error ArgumentError, "'had_an_ice_cream' is not a valid action_taken"
    end
  end
end
