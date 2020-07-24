require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::ToeflReviewComponent, type: :component do
  it 'renders a review summary for a TOEFL qualification' do
    toefl_qualification = build(
      :toefl_qualification,
      registration_number: '222222 22222',
      award_year: '2001',
      total_score: '80',
    )
    result = render_inline(described_class.new(toefl_qualification))

    [
      { position: 0, title: 'Do you have an English as a foreign language qualification?', value: 'Yes' },
      { position: 1, title: 'Type of qualification', value: 'TOEFL' },
      { position: 2, title: 'TOEFL registration number', value: '222222 22222' },
      { position: 3, title: 'Year awarded', value: '2001' },
      { position: 4, title: 'Total score', value: '80' },
    ].each do |row|
      expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
      expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:value])
    end
  end
end
