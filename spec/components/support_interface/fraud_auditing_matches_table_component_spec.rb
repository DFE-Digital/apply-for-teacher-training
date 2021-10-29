require 'rails_helper'

RSpec.describe SupportInterface::FraudAuditingMatchesTableComponent do
  let(:fraud_match1) { create(:fraud_match) }
  let(:fraud_match2) { create(:fraud_match, fraudulent: true) }

  before do
    FeatureFlag.activate(:block_fraudulent_submission)
    Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
      fraud_match2.update!(candidate_last_contacted_at: Time.zone.now)
      create(:application_form, candidate: fraud_match1.candidates.first, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
      create(:application_form, candidate: fraud_match1.candidates.second, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')

      create(:application_form, candidate: fraud_match2.candidates.first, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
      create(:application_form, candidate: fraud_match2.candidates.second, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    end
  end

  it 'does not render table data when no duplicates exist' do
    result = render_inline(described_class.new(matches: []))

    expect(result.css('td')[0]).to eq(nil)
  end

  context 'fraud match has been marked non fraudulent' do
    it 'renders a single row for a fraud match' do
      result = render_inline(described_class.new(matches: [fraud_match1]))

      expect(result.css('td')[0].text).to include('Thompson')
      expect(result.css('td')[1].text).to include('Jeffrey')
      expect(result.css('td')[1].text).to include('Joffrey')
      expect(result.css('td')[2].text).to include(fraud_match1.candidates.first.email_address)
      expect(result.css('td')[2].text).to include(fraud_match1.candidates.second.email_address)
      expect(result.css('td')[3].text).to include('Send email')
      expect(result.css('td')[4].text).to include(fraud_match1.candidate_last_contacted_at&.to_s(:govuk_date_and_time).to_s)
      expect(result.css('td')[5].text).to include('No')
      expect(result.css('td')[5].text).to include('Yes')
      expect(result.css('td')[6].text).to include('Block')
      expect(result.css('td')[6].children[1].attributes['href'].value).to include("/support/duplicate-candidate-matches/#{fraud_match1.id}/block-submission")
      expect(result.css('td')[8].text).to include('No')
      expect(result.css('td')[8].text).to include('Mark as fraudulent')
    end
  end

  context 'fraud match has been marked fraudulent' do
    it 'renders a single row for a fraud match' do
      result = render_inline(described_class.new(matches: [fraud_match2]))

      expect(result.css('td')[0].text).to include('Thompson')
      expect(result.css('td')[1].text).to include('Jeffrey')
      expect(result.css('td')[1].text).to include('Joffrey')
      expect(result.css('td')[2].text).to include(fraud_match2.candidates.first.email_address)
      expect(result.css('td')[2].text).to include(fraud_match2.candidates.second.email_address)
      expect(result.css('td')[3].text).to include('Send email')
      expect(result.css('td')[4].text).to include(fraud_match2.candidate_last_contacted_at&.to_s(:govuk_date_and_time).to_s)
      expect(result.css('td')[5].text).to include('No')
      expect(result.css('td')[5].text).to include('Yes')
      expect(result.css('td')[6].text).to include('Block')
      expect(result.css('td')[6].children[1].attributes['href'].value).to include("/support/duplicate-candidate-matches/#{fraud_match2.id}/block-submission")
      expect(result.css('td')[8].text).to include('Yes')
      expect(result.css('td')[8].text).to include('Mark as non fraudulent')
    end
  end

  it 'renders the option to unblock the candidate if currently blocked' do
    blocked_fraud_match = create(:fraud_match, blocked: true)

    create(:application_form, candidate: blocked_fraud_match.candidates.first, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    create(:application_form, candidate: blocked_fraud_match.candidates.second, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')

    result = render_inline(described_class.new(matches: [blocked_fraud_match]))

    expect(result.css('td')[6].text).to include('Unblock')
  end

  it 'renders links for each candidate to the confirm remove access path' do
    result = render_inline(described_class.new(matches: [fraud_match1]))

    expect(result.css('td')[7].text).to include("Remove #{Candidate.third.email_address}")
    expect(result.css('td')[7].children[1].attributes['href'].value).to include(Rails.application.routes.url_helpers.support_interface_fraud_auditing_matches_confirm_remove_access_path(fraud_match1.id, Candidate.third.id))
    expect(result.css('td')[7].text).to include("Remove #{Candidate.fourth.email_address}")
    expect(result.css('td')[7].children[5].attributes['href'].value).to include(Rails.application.routes.url_helpers.support_interface_fraud_auditing_matches_confirm_remove_access_path(fraud_match1.id, Candidate.fourth.id))
  end
end
