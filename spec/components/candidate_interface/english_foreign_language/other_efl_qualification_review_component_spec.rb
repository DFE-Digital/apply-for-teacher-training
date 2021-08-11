require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::OtherEflQualificationReviewComponent, type: :component do
  it 'renders a review summary for the assessment' do
    other_qualification = build(
      :other_efl_qualification,
      name: 'Some English Test',
      grade: '8',
      award_year: '2001',
    )
    result = render_inline(described_class.new(other_qualification))

    [
      { position: 0, title: 'Have you done an English as a foreign language assessment?', value: 'Yes' },
      { position: 1, title: 'Type of assessment', value: 'Some English Test' },
      { position: 2, title: 'Score or grade', value: '8' },
      { position: 3, title: 'Year completed', value: '2001' },
    ].each do |row|
      expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
      expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:value])
    end

    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path,
    )
  end

  it 'passes the `return-to` param to Change actions' do
    other_qualification = build :other_efl_qualification
    result = render_inline(described_class.new(other_qualification, return_to_application_review: true))
    
    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path('return-to' => 'application-review'),
    )
  end
end
