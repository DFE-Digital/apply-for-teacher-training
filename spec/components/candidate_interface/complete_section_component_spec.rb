require 'rails_helper'

RSpec.describe CandidateInterface::CompleteSectionComponent do
  let(:assigns) { {} }
  let(:controller) { ActionController::Base.new }
  let(:lookup_context) { ActionView::LookupContext.new(nil) }
  let(:helper) { ActionView::Base.new(lookup_context, assigns, controller) }
  let(:section_complete_form) do
    GOVUKDesignSystemFormBuilder::FormBuilder.new(
      'section_complete_form',
      CandidateInterface::SectionCompleteForm.new,
      helper,
      {},
    )
  end
  let(:application_form) { build_stubbed(:application_form, :minimum_info) }
  let(:field_name) { 'completed' }
  let(:hint_text) { 'hints' }

  it 'renders successfully' do
    result = render_inline(described_class.new(form: section_complete_form))

    expect(result.css('.govuk-form-group').text).to include t('application_form.completed_radio')
    expect(result.css('.govuk-form-group').text).to include t('application_form.incomplete_radio')
    expect(result.to_html).to include field_name
  end

  it 'renders a hint if specified' do
    result = render_inline(
      described_class.new(
        form: section_complete_form,
        hint_text: hint_text,
      ),
    )

    expect(result.to_html).to include hint_text
  end

  it 'renders a review radio button label if specified' do
    result = render_inline(
      described_class.new(
        form: section_complete_form,
        section_review: true,
      ),
    )

    expect(result.css('.govuk-form-group').text).to include t('application_form.reviewed_radio')
  end
end
