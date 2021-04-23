require 'rails_helper'

RSpec.describe CandidateInterface::CompleteSectionComponent do
  let(:section_complete_form) { CandidateInterface::SectionCompleteForm.new }
  let(:summary_component) { ViewComponent::Base.new }
  let(:application_form) { create(:application_form) }
  let(:path) { Rails.application.routes.url_helpers.candidate_interface_application_form_path }
  let(:field_name) { 'completed' }
  let(:request_method) { 'post' }
  let(:hint_text) { 'hints' }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(
        section_complete_form: section_complete_form,
        path: path,
        request_method: request_method,
      ),
    )

    expect(result.css('.govuk-form-group').text).to include 'I have completed this section'
    expect(result.to_html).to include path
    expect(result.to_html).to include request_method
    expect(result.to_html).to include field_name
  end

  it 'renders a hint if specified' do
    result = render_inline(
      described_class.new(
        section_complete_form: section_complete_form,
        path: path,
        request_method: request_method,
        hint_text: hint_text,
      ),
    )

    expect(result.to_html).to include complete_hint_text
  end

  it 'renders a review radio button label if specified' do
    result = render_inline(
      described_class.new(
        section_complete_form: section_complete_form,
        path: path,
        request_method: request_method,
        section_review: true,
      ),
    )

    expect(result.css('.govuk-form-group').text).to include 'I have reviewed this section'
  end
end
