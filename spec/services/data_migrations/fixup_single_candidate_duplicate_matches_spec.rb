require 'rails_helper'

RSpec.describe DataMigrations::FixupSingleCandidateDuplicateMatches do
  it 'fixes two single candidate fraud matches that should have been one' do
    alice = create(:candidate, email_address: 'alice@example.com')
    alices_application_form = create(
      :application_form,
      :duplicate_candidates,
      candidate: alice,
    )
    create(
      :fraud_match,
      last_name: alices_application_form.last_name,
      postcode: alices_application_form.postcode,
      date_of_birth: alices_application_form.date_of_birth,
      candidates: [alice],
    )

    bob = create(:candidate, email_address: 'bob@example.com')
    bobs_application_form = create(
      :application_form,
      :duplicate_candidates,
      last_name: " #{ApplicationForm.last.last_name.upcase} ",
      postcode: "#{ApplicationForm.last.postcode.downcase} ",
      candidate: bob,
    )
    create(
      :fraud_match,
      last_name: bobs_application_form.last_name,
      postcode: bobs_application_form.postcode,
      date_of_birth: bobs_application_form.date_of_birth,
      candidates: [bob],
    )

    described_class.new.change

    expect(FraudMatch.count).to be(1)
    expect(FraudMatch.first.candidates).to match_array([bob, alice])
  end

  it 'ignores fraud matches with two candidates' do
    alice = create(:candidate, email_address: 'alice@example.com')
    alices_application_form = create(
      :application_form,
      :duplicate_candidates,
      candidate: alice,
    )
    bob = create(:candidate, email_address: 'bob@example.com')
    bobs_application_form = create(
      :application_form,
      :duplicate_candidates,
      last_name: " #{ApplicationForm.last.last_name.upcase} ",
      postcode: "#{ApplicationForm.last.postcode.downcase} ",
      candidate: bob,
    )
    fraud_match = create(
      :fraud_match,
      last_name: bobs_application_form.last_name,
      postcode: bobs_application_form.postcode,
      date_of_birth: bobs_application_form.date_of_birth,
      candidates: [alice, bob],
    )

    described_class.new.change

    expect(FraudMatch.count).to be(1)
    expect(fraud_match.reload.candidates).to match_array([bob, alice])
  end
end
