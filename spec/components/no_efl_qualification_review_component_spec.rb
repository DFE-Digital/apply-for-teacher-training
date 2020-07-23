require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::NoEflQualificationReviewComponent, type: :component do
  it 'renders a review summary for a "no qualification" statement of english proficiency' do
    english_proficiency = build(
      :english_proficiency,
      :no_qualification,
      no_qualification_details: "I'm working on it.",
    )

    result = render_inline described_class.new(english_proficiency)

    row = {
      position: 0,
      title: 'Do you have an English as a foreign language qualification?',
      answer: 'No, I do not have an English as a foreign language qualification',
      detail: "I'm working on it.",
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:detail])
  end

  it 'renders a review summary for a "qualification not needed" statement of english proficiency' do
    english_proficiency = build(:english_proficiency, :qualification_not_needed)

    result = render_inline described_class.new(english_proficiency)

    row = {
      position: 0,
      title: 'Do you have an English as a foreign language qualification?',
      answer: 'No, English is not a foreign language to me',
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
  end
end
