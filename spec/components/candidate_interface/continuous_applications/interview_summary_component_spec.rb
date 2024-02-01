require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::InterviewSummaryComponent do
  let(:interview) { create(:interview) }

  subject(:component) do
    render_inline(described_class.new(interview:))
  end

  it 'displays the date and time of the interview' do
    expect(component.text).to include("You have an interview scheduled for #{interview.date_and_time.to_fs(:govuk_date)} at #{interview.date_and_time.to_fs(:govuk_time)}.")
  end

  context 'when there is no location or details' do
    let(:interview) { create(:interview, additional_details: nil, location: nil) }

    it 'does not show extra information' do
      expect(component.text).not_to include('Information from provider:')
    end
  end

  context 'when there is a location' do
    let(:interview) { create(:interview, additional_details: nil, location: '123 Fake Street') }

    it 'shows the location in inset text' do
      expect(component).to have_content('Information from provider:')
      expect(component.css('.govuk-inset-text')).to have_content('123 Fake Street')
    end
  end

  context 'when there is a details' do
    let(:interview) { create(:interview, additional_details: 'Bring your CV', location: nil) }

    it 'shows the details in inset text' do
      expect(component).to have_content('Information from provider:')
      expect(component.css('.govuk-inset-text')).to have_content('Bring your CV')
    end
  end
end
