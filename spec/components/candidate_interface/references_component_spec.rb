require 'rails_helper'

RSpec.describe CandidateInterface::ReferencesComponent, type: :component do
  let(:url_helpers) { Rails.application.routes.url_helpers }
  let(:reference_condition) { nil }
  let(:reference) { create(:reference, feedback_status: 'feedback_requested', requested_at: 2.seconds.ago) }
  let(:result) { render_inline(described_class.new(references: [reference], reference_condition:)) }

  context 'when reference condition' do
    context 'when is met' do
      let(:reference_condition) { create(:reference_condition, status: :met) }

      it 'renders the correct status' do
        expect(result.text).to include 'Received by training provider'
      end
    end

    context 'when is pending' do
      let(:reference_condition) { create(:reference_condition, status: :pending) }

      it 'renders the correct status' do
        expect(result.css('.govuk-tag').text).to include 'Requested'
      end
    end
  end

  context 'when feedback provided' do
    let(:reference) { create(:reference, feedback_status: 'feedback_provided') }

    it 'renders the correct reference link' do
      expect(result.css('.govuk-link')[0].attributes['href'].value).to eq(url_helpers.candidate_interface_application_offer_dashboard_reference_path(reference.id))
      expect(result.css('.govuk-link')[0].text).to eq reference.name
    end

    it 'renders the correct status' do
      expect(result.css('.govuk-tag').text).to include 'Received by training provider'
    end
  end
end
