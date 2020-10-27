require 'rails_helper'

RSpec.describe SupportInterface::ApplicationSummaryComponent do
  describe '#rows' do
    it 'includes a link to a UCAS match if present' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate: candidate)
      create(:ucas_match, candidate: candidate, matching_state: 'new_match')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('UCAS matching data')
      expect(result.css('.govuk-summary-list__value').text).to include('View matching data for this candidate')
    end

    it 'reports no UCAS matches if there are none' do
      candidate = create(:candidate)
      application_form = create(:application_form, candidate: candidate)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('UCAS matching data')
      expect(result.css('.govuk-summary-list__value').text).to include('No matching data for this candidate')
    end
  end
end
