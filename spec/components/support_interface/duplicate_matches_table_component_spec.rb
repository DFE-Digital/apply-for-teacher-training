require 'rails_helper'
require 'pagy'

RSpec.describe SupportInterface::DuplicateMatchesTableComponent do
  include Pagy::Backend

  before do
    @duplicate_match1 = build(
      :duplicate_match,
      id: 123,
      last_name: 'Thompson',
      date_of_birth: '1998-08-08',
      postcode: 'W6 9BH',
      candidates: build_list(:candidate, 3),
      created_at: Time.zone.local(2022, 1, 4, 12),
    )
    @duplicate_match2 = build(
      :duplicate_match,
      id: 456,
      last_name: 'Roberts',
      date_of_birth: '1973-02-15',
      postcode: 'GU1 6XO',
      candidates: build_list(:candidate, 2),
      created_at: Time.zone.local(2022, 1, 1, 12),
    )
  end

  it 'renders the correct match descriptions' do
    _, matches = pagy_array([@duplicate_match1, @duplicate_match2], page: 1, items: SupportInterface::DuplicateMatchesController::DUPLICATE_MATCHES_PER_PAGE)

    result = render_inline(
      described_class.new(
        matches: matches,
      ),
    )

    expect(result.css('tbody tr')[0].text).to include('3 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(result.css('tbody tr')[0].text).to include('4 Jan 2022')
    expect(result.css('tbody tr')[1].text).to include('2 candidates with postcode GU1 6XO and DOB 15 Feb 1973')
    expect(result.css('tbody tr')[1].text).to include('1 Jan 2022')
  end
end
