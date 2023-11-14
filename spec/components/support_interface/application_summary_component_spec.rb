require 'rails_helper'

RSpec.describe SupportInterface::ApplicationSummaryComponent do
  describe '#rows' do
    it 'indicates if the application was submitted less than 5 days ago' do
      submitted_at = 3.business_days.ago
      candidate = create(:candidate)
      application_form = create(:completed_application_form, candidate:, submitted_at:)

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Submitted')
      expect(result.css('.govuk-summary-list__value').text).to include('Less than 5 days ago')
    end

    it 'indicates if the application was submitted over 5 days ago' do
      submitted_at = 6.business_days.ago
      candidate = create(:candidate)
      application_form = create(:completed_application_form, candidate:, submitted_at:)

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Submitted')
      expect(result.css('.govuk-summary-list__value').text).to include('Over 5 days ago')
    end

    context 'when the unlock editing feature flag is active' do
      before do
        FeatureFlag.activate(:unlock_application_for_editing)
      end

      it 'renders the editable row' do
        result = render_inline(described_class.new(application_form: create(:completed_application_form)))

        expect(result.css('.govuk-summary-list__key').text).to include('Is this application editable')
      end
    end

    context 'when the unlock editing feature flag is inactive' do
      before do
        FeatureFlag.deactivate(:unlock_application_for_editing)
      end

      it 'does not render the editable row' do
        result = render_inline(described_class.new(application_form: create(:completed_application_form)))

        expect(result.css('.govuk-summary-list__key').text).not_to include('Is this application editable')
      end
    end
  end
end
