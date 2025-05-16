require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent, type: :component do
  it 'renders a review summary for an IELTS qualification' do
    application_form = create(:application_form, first_nationality: 'Iranian')
    create(
      :english_proficiency,
      :with_ielts_qualification,
      application_form:,
    )

    render_inline described_class.new(application_form:)

    expect(rendered_content).to summarise(
      key: 'Type of assessment',
      value: 'IELTS',
    )

    expect(rendered_content).to summarise(
      key: 'Test Report Form (TRF) number',
      value: '123456',
    )

    expect(rendered_content).to summarise(
      key: 'Year completed',
      value: '1999',
    )

    expect(rendered_content).to summarise(
      key: 'Overall band score',
      value: '6.5',
    )
  end

  it 'renders a review summary for an TOEFL qualification' do
    application_form = create(:application_form, first_nationality: 'South African')
    create(
      :english_proficiency,
      :with_toefl_qualification,
      application_form:,
    )

    render_inline described_class.new(application_form:)

    expect(rendered_content).to summarise(
      key: 'Type of assessment',
      value: 'TOEFL',
    )

    expect(rendered_content).to summarise(
      key: 'TOEFL registration number',
      value: '123456',
    )

    expect(rendered_content).to summarise(
      key: 'Year completed',
      value: '1999',
    )

    expect(rendered_content).to summarise(
      key: 'Total score',
      value: '20',
    )
  end

  it 'renders a review summary for another qualification' do
    application_form = create(:application_form, first_nationality: 'Argentinian')
    create(
      :english_proficiency,
      :with_other_efl_qualification,
      application_form:,
    )

    render_inline described_class.new(application_form:)

    expect(rendered_content).to summarise(
      key: 'Type of assessment',
      value: 'Cockney Rhyming Slang Proficiency Test',
    )

    expect(rendered_content).to summarise(
      key: 'Year completed',
      value: '2001',
    )

    expect(rendered_content).to summarise(
      key: 'Score or grade',
      value: '10',
    )
  end

  it 'renders a review for a "no qualification" statement of english proficiency' do
    application_form = create(:application_form, first_nationality: 'French')
    create(
      :english_proficiency,
      :no_qualification,
      application_form:,
      no_qualification_details: 'I’m working on it.',
    )

    result = render_inline described_class.new(application_form:)

    row = {
      position: 0,
      title: 'Have you done an English as a foreign language assessment?',
      answer: 'No, I have not done an English as a foreign language assessment',
      detail: 'I’m working on it.',
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:detail])
  end

  it 'renders a review summary for a "qualification not needed" statement of english proficiency' do
    application_form = create(:application_form, first_nationality: 'French')
    create(
      :english_proficiency,
      :qualification_not_needed,
      application_form:,
    )

    result = render_inline described_class.new(application_form:)

    row = {
      position: 0,
      title: 'Have you done an English as a foreign language assessment?',
      answer: 'No, English is not a foreign language to me',
    }
    expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
    expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:answer])
  end
end
