require 'rails_helper'

RSpec.describe SupportInterface::DuplicateMatchesTableComponent do
  before do
    @fraud_match1 = build(
      :fraud_match,
      id: 123,
      last_name: 'Thompson',
      date_of_birth: '1998-08-08',
      postcode: 'W6 9BH',
      candidates: build_list(:candidate, 3),
      created_at: Time.zone.local(2022, 1, 4, 12),
    )
    @fraud_match2 = build(
      :fraud_match,
      id: 456,
      last_name: 'Roberts',
      date_of_birth: '1973-02-15',
      postcode: 'GU1 6XO',
      candidates: build_list(:candidate, 2),
      created_at: Time.zone.local(2022, 1, 1, 12),
    )
  end

  it 'renders the correct match descriptions' do
    result = render_inline(
      described_class.new(matches: [@fraud_match1, @fraud_match2]),
    )

    expect(result.css('tbody tr')[0].text).to include('3 candidates with postcode W6 9BH and DOB 08/08/1998')
    expect(result.css('tbody tr')[0].text).to include('4 Jan 2022')
    expect(result.css('tbody tr')[1].text).to include('2 candidates with postcode GU1 6XO and DOB 15/02/1973')
    expect(result.css('tbody tr')[1].text).to include('1 Jan 2022')
  end
end
