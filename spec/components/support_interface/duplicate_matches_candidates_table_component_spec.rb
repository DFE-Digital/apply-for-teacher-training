require 'rails_helper'

RSpec.describe SupportInterface::DuplicateMatchesCandidatesTableComponent do
  before do
    @fraud_match1 = build(
      :fraud_match,
      id: 123,
      last_name: 'Thompson',
      date_of_birth: '2000-03-07',
      postcode: 'W6 9BH',
      candidates: [
        create(:candidate,
          application_forms: [create(:application_form, :minimum_info, submitted_at: Time.local(2022, 1, 1, 12), date_of_birth: Date.new(2000, 3, 7), postcode: 'W6 9BH')],
          account_locked: true,
        ),
        create(:candidate,
          application_forms: [create(:application_form, :minimum_info, date_of_birth: Date.new(2000, 3, 7), postcode: 'W6 9BH')],
          submission_blocked: true,
        ),
      ],
      created_at: Time.local(2022, 1, 4, 12),
    )
  end

  it 'renders the correct match descriptions' do
    result = render_inline(
      described_class.new(@fraud_match1),
    )

    @fraud_match1.candidates.each_with_index do |candidate, index|
      expect(result.css('a[href]')[index].attributes['href'].value).to eq(Rails.application.routes.url_helpers.support_interface_candidate_path(candidate))
      expect(result.css('a')[index].text).to eq(candidate.email_address)
      expect(result.text).to include(candidate.created_at.to_s(:govuk_date_and_time))
      expect(result.text).to include(candidate.current_application.full_name)
      expect(result.text).to include(candidate.current_application.date_of_birth.to_s(:slash_delimited_date))
      candidate.current_application.full_address.each do |address_line|
        expect(result.text).to include(address_line)
      end
      expect(result.text).to include(candidate.current_application.submitted_at&.to_s(:govuk_date_and_time) || 'Not submitted')
      expect(result.text).to include(index.zero? ? 'Account locked' : 'Application submission blocked')
    end
  end
end
