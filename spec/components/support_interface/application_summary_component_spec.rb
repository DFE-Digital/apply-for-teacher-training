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

    context 'when the candidate has a OneLogin account' do
      it 'displays "Yes" for the One Login account row' do
        candidate = create(:candidate)
        candidate.create_one_login_auth!(
          token: '123',
          email_address: candidate.email_address,
        )
        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Has One Login account')
        expect(result.css('.govuk-summary-list__value').text).to include('Yes')
      end
    end

    context 'when the candidate does not have a OneLogin account' do
      it 'displays "No" for the One Login account row' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Has One Login account')
        expect(result.css('.govuk-summary-list__value').text).to include('No')
      end
    end

    context 'when the candidate had a OneLogin account but it was deleted' do
      it 'displays "No" for the One Login account row' do
        candidate = create(:candidate)
        one_login_auth = candidate.create_one_login_auth!(
          token: '123',
          email_address: candidate.email_address,
        )

        one_login_auth.delete
        candidate.reload

        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Has One Login account')
        expect(result.css('.govuk-summary-list__value').text).to include('No')
      end
    end
  end
end
