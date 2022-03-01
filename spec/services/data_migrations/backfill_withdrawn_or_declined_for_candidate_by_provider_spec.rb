require 'rails_helper'

RSpec.describe DataMigrations::BackfillWithdrawnOrDeclinedForCandidateByProvider do
  let(:withdrawn_application) { create(:application_choice, :withdrawn, withdrawn_or_declined_for_candidate_by_provider: nil) }
  let(:declined_application) { create(:application_choice, :with_declined_offer, withdrawn_or_declined_for_candidate_by_provider: nil) }

  it 'backfills withdrawn_or_declined_for_candidate_by_provider to true with provider actor' do
    create(:withdrawn_at_candidates_request_audit, application_choice: withdrawn_application)
    create(:declined_at_candidates_request_audit, application_choice: declined_application)

    described_class.new.change

    expect(withdrawn_application.reload.withdrawn_or_declined_for_candidate_by_provider).to be(true)
    expect(declined_application.reload.withdrawn_or_declined_for_candidate_by_provider).to be(true)
  end

  it 'backfills withdrawn_or_declined_for_candidate_by_provider to false with non-provider actors' do
    create(:withdrawn_at_candidates_request_audit, user: create(:candidate), application_choice: withdrawn_application)
    create(:declined_at_candidates_request_audit, user: create(:candidate), application_choice: declined_application)

    described_class.new.change

    expect(withdrawn_application.reload.withdrawn_or_declined_for_candidate_by_provider).to be(false)
    expect(declined_application.reload.withdrawn_or_declined_for_candidate_by_provider).to be(false)
  end
end
