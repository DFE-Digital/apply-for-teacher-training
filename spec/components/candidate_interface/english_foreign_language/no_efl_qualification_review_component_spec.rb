require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::NoEflQualificationReviewComponent, type: :component do
  it 'renders a review summary for a "no qualification" statement of english proficiency' do
    english_proficiency = build(
      :english_proficiency,
      :no_qualification,
      no_qualification_details: 'I’m working on it.',
    )

    result = render_inline described_class.new(english_proficiency)

    row = {
      position: 0,
      title: 'Have you done an English as a foreign language assessment?',
      answer: 'No, I have not done an English as a foreign language assessment',
      detail: 'I’m working on it.',
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:detail])
    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path,
    )
  end

  it 'renders a review summary for a "qualification not needed" statement of english proficiency' do
    english_proficiency = build(:english_proficiency, :qualification_not_needed)

    result = render_inline described_class.new(english_proficiency)

    row = {
      position: 0,
      title: 'Have you done an English as a foreign language assessment?',
      answer: 'No, English is not a foreign language to me',
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
  end

  it 'passes the `return-to` param to Change actions' do
    english_proficiency = build(:english_proficiency, :qualification_not_needed)
    result = render_inline(described_class.new(english_proficiency, return_to_application_review: true))
    
    expect(result.css('.govuk-summary-list__actions a')[0][:href]).to eq(
      Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path('return-to' => 'application-review'),
    )
  end
end
