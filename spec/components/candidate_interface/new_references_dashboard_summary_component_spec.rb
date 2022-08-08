require 'rails_helper'

RSpec.describe CandidateInterface::NewReferencesDashboardSummaryComponent do

  it 'renders a reference correctly' do
    reference = create(:reference, feedback_status: 'feedback_provided')
    result = render_inline(described_class.new(reference: reference.id))

    expect(result.css('.govuk-table__header')[0].text).to eq 'Name'
    expect(result.css('.govuk-table__cell')[0].text).to eq reference.name
    expect(result.css('.govuk-table__header')[1].text).to eq 'Email'
    expect(result.css('.govuk-table__cell')[1].text).to eq reference.email_address
    expect(result.css('.govuk-table__header')[2].text).to eq 'Type'
    expect(result.css('.govuk-table__cell')[2].text).to eq reference.referee_type
    expect(result.css('.govuk-table__header')[3].text).to eq 'Relationship to you'
    expect(result.css('.govuk-table__cell')[3].text).to eq reference.relationship
    expect(result.css('.govuk-table__header')[4].text).to eq 'Status'
    expect(result.css('.govuk-table__cell')[4].text).to eq 'Reference received'
    expect(result.css('.govuk-table__header')[5].text).to eq 'History'
  end

  context 'when the reference is requested' do
    it 'renders the correct actions' do
      reference = create(:reference, feedback_status: 'feedback_requested')
      result = render_inline(described_class.new(reference: reference.id))

      expect(result.text).to include 'Send a reminder'
      expect(result.text).to include 'Cancel request'
    end
  end

  context 'when the reference is a status other than requested' do
    it 'does not render the actions' do
      reference = create(:reference, feedback_status: 'feedback_provided')
      result = render_inline(described_class.new(reference: reference.id))

      expect(result.text).not_to include 'Send a reminder'
      expect(result.text).not_to include 'Cancel request'
    end
  end
end
