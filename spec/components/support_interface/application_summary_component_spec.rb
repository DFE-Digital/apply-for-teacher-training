require 'rails_helper'

RSpec.describe SupportInterface::ApplicationSummaryComponent do
  describe '#rows' do
    it 'indicates if the application was submitted less than 5 days ago' do
      submitted_at = 3.business_days.ago
      candidate = create(:candidate)
      application_form = create(:completed_application_form, candidate: candidate, submitted_at: submitted_at)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Submitted')
      expect(result.css('.govuk-summary-list__value').text).to include('Less than 5 days ago')
    end

    it 'indicates if the application was submitted over 5 days ago' do
      submitted_at = 6.business_days.ago
      candidate = create(:candidate)
      application_form = create(:completed_application_form, candidate: candidate, submitted_at: submitted_at)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.govuk-summary-list__key').text).to include('Submitted')
      expect(result.css('.govuk-summary-list__value').text).to include('Over 5 days ago')
    end
  end
end
