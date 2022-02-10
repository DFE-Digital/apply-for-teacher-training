require 'rails_helper'

RSpec.describe DuplicateMatchSendEmail, sidekiq: true do
  subject(:send_email) { described_class.new.call }

  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }
  let(:candidate3) { create(:candidate, email_address: 'exemplar3@example.com') }

  before do
    Timecop.freeze(Time.zone.local(2022, 1, 28)) do
      create(:duplicate_match, candidates: [candidate1, candidate2])
    end

    Timecop.freeze(Time.zone.local(2022, 1, 1)) do
      create(:duplicate_match, candidates: [candidate3])
    end

    send_email
  end

  it 'sends email to the right candidates in the right period' do
    expect(ActionMailer::Base.deliveries.map(&:to)).to match_array(
      [
        ['exemplar1@example.com'],
        ['exemplar2@example.com'],
      ],
    )
  end
end
