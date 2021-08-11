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
      { position: 0, title: 'Have you done an English as a foreign language assessment?', value: 'Yes' },
      { position: 1, title: 'Type of assessment', value: 'TOEFL' },
      { position: 2, title: 'TOEFL registration number', value: '222222 22222' },
      { position: 3, title: 'Year completed', value: '2001' },
      { position: 4, title: 'Total score', value: '80' },
    ].each do |row|
      expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
      expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:value])
    end

    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path,
    )
  end

  it 'passes the `return-to` param to Change actions' do
    toefl_qualification = build(:toefl_qualification)
    result = render_inline(described_class.new(toefl_qualification, return_to_application_review: true))
    
    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path('return-to' => 'application-review'),
    )
  end
end
