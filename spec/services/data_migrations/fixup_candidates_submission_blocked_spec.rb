require 'rails_helper'

RSpec.describe DataMigrations::FixupCandidatesSubmissionBlocked do
  before do
    @candidate_one = create(:candidate, submission_blocked: true)
    @candidate_two = create(:candidate, submission_blocked: true)

    @duplicate_match_one = create(:duplicate_match, candidates: [@candidate_one, @candidate_two], blocked: true)

    @candidate_third = create(:candidate, submission_blocked: true)
    @candidate_fourth = create(:candidate, submission_blocked: true)

    @duplicate_match_two = create(:duplicate_match, candidates: [@candidate_third, @candidate_fourth], blocked: false)
  end

  it 'updates blocked submissions as false if they were not blocked deliberately' do
    described_class.new.change
    expect(@candidate_one.reload).to be_submission_blocked
    expect(@candidate_two.reload).to be_submission_blocked

    expect(@candidate_third.reload).not_to be_submission_blocked
    expect(@candidate_fourth.reload).not_to be_submission_blocked
  end
end
