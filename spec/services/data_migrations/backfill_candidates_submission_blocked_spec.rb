require 'rails_helper'

RSpec.describe DataMigrations::BackfillCandidatesSubmissionBlocked do
  before do
    blocked_fraud_match = FraudMatch.create(blocked: true)
    non_blocked_fraud_match = FraudMatch.create(blocked: false)

    @blocked_duplicate_candidates = create_list(
      :candidate,
      2,
      fraud_match: blocked_fraud_match,
    )
    @non_blocked_duplicate_candidates = create_list(
      :candidate,
      2,
      fraud_match: non_blocked_fraud_match,
    )
    @non_duplicate_candidate = create(:candidate)
  end

  it 'sets submission_blocked only on the correct candidates' do
    described_class.new.change

    @blocked_duplicate_candidates.each do |candidate|
      expect(candidate.reload.submission_blocked).to be(true)
    end

    @non_blocked_duplicate_candidates.each do |candidate|
      expect(candidate.reload.submission_blocked).to be(false)
    end

    expect(@non_duplicate_candidate.reload.submission_blocked).to be(false)
  end
end
