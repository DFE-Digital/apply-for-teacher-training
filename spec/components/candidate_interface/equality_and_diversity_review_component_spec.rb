require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversityReviewComponent do
  let(:application_form) do
    build_stubbed(
      :application_form,
      equality_and_diversity: { 'sex' => 'male' },
    )
  end

  it 'renders component with correct equality and diversity information' do
    result = render_inline(described_class.new(application_form: application_form))

    expect(result.css('.govuk-summary-list__key').text).to include('Sex')
    expect(result.css('.govuk-summary-list__value').text).to include('Male')
  end

  context 'when editable' do
    it 'renders the component with change links' do
      result = render_inline(described_class.new(application_form: application_form, editable: true))

      expect(result.text).to include('Change sex')
    end
  end

  context 'when not editable' do
    it 'renders the component with change links' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.text).not_to include('Change sex')
    end
  end
end
