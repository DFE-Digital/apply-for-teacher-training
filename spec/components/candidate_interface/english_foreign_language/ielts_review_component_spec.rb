require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::IeltsReviewComponent, type: :component do
  it 'renders a review summary for an IELTS qualification' do
    ielts_qualification = build(
      :ielts_qualification,
      trf_number: '111111',
      award_year: '2001',
      band_score: '8',
    )
    render_inline(described_class.new(ielts_qualification))

    expect(rendered_content).to summarise(
      key: 'Have you done an English as a foreign language assessment?',
      value: 'Yes',
      action: {
        text: 'Change whether or not you have a qualification',
        href: Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_edit_start_path,
      },
    )

    expect(rendered_content).to summarise(
      key: 'Type of assessment',
      value: 'IELTS',
      action: {
        text: 'Change type of assessment',
        href: Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_type_path,
      },
    )

    expect(rendered_content).to summarise(
      key: 'Test report form (TRF) number',
      value: '111111',
      action: {
        text: 'Change TRF number',
        href: Rails.application.routes.url_helpers.candidate_interface_edit_ielts_path,
      },
    )

    expect(rendered_content).to summarise(
      key: 'Year completed',
      value: '2001',
      action: {
        text: 'Change year completed',
        href: Rails.application.routes.url_helpers.candidate_interface_edit_ielts_path,
      },
    )

    expect(rendered_content).to summarise(
      key: 'Overall band score',
      value: '8',
      action: {
        text: 'Change overall band score',
        href: Rails.application.routes.url_helpers.candidate_interface_edit_ielts_path,
      },
    )
  end

  it 'passes the `return-to` param to Change actions' do
    ielts_qualification = build(
      :ielts_qualification,
      trf_number: '111111',
      award_year: '2001',
      band_score: '8',
    )
    result = render_inline(described_class.new(ielts_qualification, return_to_application_review: true))

    expect(rendered_content).to summarise(
      key: 'Test report form (TRF) number',
      value: '111111',
      action: {
        text: 'Change TRF number',
        href: Rails.application.routes.url_helpers.candidate_interface_edit_ielts_path('return-to' => 'application-review'),
      },
    )
  end
end
