require 'rails_helper'

RSpec.describe CandidateInterface::CompleteSectionComponent do
  let(:section_complete_form) { CandidateInterface::SectionCompleteForm.new }
  let(:application_form) { build_stubbed(:application_form, :minimum_info) }
  let(:review_component) { CandidateInterface::InterviewPreferencesReviewComponent.new(application_form: application_form) }
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
        review_component: review_component,
      ),
    )

    expect(result.css('.govuk-form-group').text).to include t('application_form.completed_radio')
    expect(result.css('.govuk-form-group').text).to include t('application_form.incomplete_radio')
    expect(result.css('.app-summary-card').text).to include 'Interview needs'
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
        review_component: review_component,
      ),
    )

    expect(result.to_html).to include hint_text
  end

  it 'renders a review radio button label if specified' do
    result = render_inline(
      described_class.new(
        section_complete_form: section_complete_form,
        path: path,
        request_method: request_method,
        section_review: true,
        review_component: review_component,
      ),
    )

    expect(result.css('.govuk-form-group').text).to include t('application_form.reviewed_radio')
  end
end
