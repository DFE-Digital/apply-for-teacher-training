require 'rails_helper'

RSpec.describe CandidateInterface::ReferencesComponent, type: :component do
  let(:url_helpers) { Rails.application.routes.url_helpers }

  context 'when feedback provided' do
    let(:reference) { create(:reference, feedback_status: 'feedback_provided') }
    let(:application_form) { create(:application_form, application_references: [reference]) }
    let(:result) { render_inline(described_class.new(application_form:)) }

    it 'renders the correct reference link' do
      expect(result.css('.govuk-link')[0].attributes['href'].value).to eq(url_helpers.candidate_interface_application_offer_dashboard_reference_path(reference.id))
      expect(result.css('.govuk-link')[0].text).to eq reference.name
    end

    it 'renders the correct status' do
      expect(result.css('.govuk-tag').text).to include 'Reference completed'
    end
  end
end
