require 'rails_helper'

RSpec.describe SupportInterface::FraudAuditingMatchesTableComponent do
  let(:fraud_match1) { create(:fraud_match) }
  let(:fraud_match2) { create(:fraud_match, fraudulent: true) }

  before do
    FeatureFlag.activate(:block_fraudulent_submission)
    Timecop.freeze(Time.zone.local(2020, 8, 23, 12)) do
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
      expect(result.css('td')[3].text).to include('')
      expect(result.css('td')[4].text).to include('')
      expect(result.css('td')[5].text).to include('No')
      expect(result.css('td')[5].text).to include('Mark as fraudulent')
      expect(result.css('td')[6].text).to include('No')
      expect(result.css('td')[6].text).to include('Yes')
      expect(result.css('td')[7].text).to include('Block')
      expect(result.css('td')[7].children[1].attributes['href'].value).to include("/support/fraud-auditing-dashboard/#{fraud_match1.id}/block-submission")
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
      expect(result.css('td')[3].text).to include('')
      expect(result.css('td')[4].text).to include('')
      expect(result.css('td')[5].text).to include('Yes')
      expect(result.css('td')[5].text).to include('Mark as non fraudulent')
      expect(result.css('td')[6].text).to include('No')
      expect(result.css('td')[6].text).to include('Yes')
      expect(result.css('td')[7].text).to include('Block')
      expect(result.css('td')[7].children[1].attributes['href'].value).to include("/support/fraud-auditing-dashboard/#{fraud_match2.id}/block-submission")
    end
  end

  it 'does not render the block submission functionality if alreay blocked' do
    blocked_fraud_match = create(:fraud_match, blocked: true)

    create(:application_form, candidate: blocked_fraud_match.candidates.first, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    create(:application_form, candidate: blocked_fraud_match.candidates.second, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')

    result = render_inline(described_class.new(matches: [blocked_fraud_match]))

    expect(result.css('td')[7].text).to include('Candidate blocked')
    expect(result.css('td')[7].text).not_to include('Block')
  end
end
