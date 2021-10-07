require 'rails_helper'

RSpec.describe SupportInterface::FraudAuditingMatchesTableComponent do
  let(:candidate1) { create(:candidate, email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, email_address: 'exemplar2@example.com') }
  let(:fraud_match) { create(:fraud_match, candidates: [candidate1, candidate2]) }

  before do
    Timecop.freeze(Time.zone.local(2020, 8, 23, 12, 0o0, 0o0)) do
      create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now)
      create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
    end
  end

  it 'does not render table data when no duplicates exist' do
    result = render_inline(described_class.new(matches: []))

    expect(result.css('td')[0]).to eq(nil)
  end

  it 'renders a single row for a fraud match' do
    result = render_inline(described_class.new(matches: [fraud_match]))

    expect(result.css('td')[0].text).to include('Thompson')
    expect(result.css('td')[1].text).to include('Jeffrey')
    expect(result.css('td')[1].text).to include('Joffrey')
    expect(result.css('td')[2].text).to include('exemplar1@example.com')
    expect(result.css('td')[2].text).to include('exemplar2@example.com')
    expect(result.css('td')[3].text).to include('')
    expect(result.css('td')[4].text).to include('')
    expect(result.css('td')[5].text).to include('No')
    expect(result.css('td')[6].text).to include('No')
    expect(result.css('td')[6].text).to include('Yes')
    expect(result.css('td')[7].text).to include('')
  end
end
