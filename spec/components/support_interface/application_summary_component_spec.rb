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

    it 'renders the editable row' do
      result = render_inline(described_class.new(application_form: create(:completed_application_form)))

      expect(result.css('.govuk-summary-list__key').text).to include('Is this application editable')
    end

    context 'when the candidate has a OneLogin account' do
      it 'displays "Yes" for the One Login account row' do
        candidate = create(:candidate)
        candidate.create_one_login_auth!(
          token: '123',
          email_address: 'some_other_email_address@gmail.com',
        )
        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Has GOV.UK One Login')
        expect(result.css('.govuk-summary-list__value').text).to include('Yes (some_other_email_address@gmail.com)')
      end
    end

    context 'when the candidate does not have a OneLogin account' do
      it 'displays "No" for the One Login account row' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Has GOV.UK One Login')
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

        expect(result.css('.govuk-summary-list__key').text).to include('Has GOV.UK One Login')
        expect(result.css('.govuk-summary-list__value').text).to include('No')
      end
    end

    context 'when the candidate has opted into sharing application details with providers but still has pending decisions' do
      it 'displays "Opted in (not findable)" for the Find a Candidate opt-in status row' do
        application_form = create(:application_form)

        create(:candidate_preference, application_form:)
        create(:application_choice, status: :awaiting_provider_decision, application_form:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate opt-in status')
        expect(result.css('.govuk-summary-list__value').text).to include('Opted in (not findable)')
      end
    end

    context 'when the candidate has opted into sharing application details with providers and has no active applications' do
      it 'displays "Currently findable by providers" for the Find a Candidate opt-in status row' do
        candidate = create(:candidate)
        application_form = create(:application_form, candidate:)
        create(:candidate_pool_application, application_form: application_form)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate opt-in status')
        expect(result.css('.govuk-summary-list__value').text).to include('Currently findable by providers')
      end
    end

    context 'when the candidate has opted out of sharing application details with providers' do
      it 'displays "Opted out" for the Find a Candidate opt-in status row' do
        application_form = create(:application_form)

        create(:candidate_preference, pool_status: 'opt_out', application_form:)
        create(:application_choice, status: :withdrawn, application_form:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate opt-in status')
        expect(result.css('.govuk-summary-list__value').text).to include('Opted out')
      end
    end

    context 'when the candidate has not yet submitted a decision for sharing application details with providers' do
      it 'displays "No status recorded" for the Find a Candidate opt-in status row and the location preferences row does not display' do
        candidate = create(:candidate)
        application_form = create(:completed_application_form, candidate:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate opt-in status')
        expect(result.css('.govuk-summary-list__value').text).to include('No status recorded')

        expect(result.css('.govuk-summary-list__key').text).not_to include('Find a Candidate location preferences')
      end
    end

    context 'when the candidate has published location preferences' do
      it 'displays the location preferences and selected radius in a list' do
        application_form = create(:application_form)
        candidate_preference = create(:candidate_preference, application_form:)

        create(:application_choice, status: :withdrawn, application_form:)
        create(:candidate_location_preference, :manchester, candidate_preference:)
        create(:candidate_location_preference, :liverpool, candidate_preference:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate location preferences')
        expect(result.css('.govuk-summary-list__value').text).to include('Within 10.0 miles of Manchester')
        expect(result.css('.govuk-summary-list__value').text).to include('Within 10.0 miles of Liverpool')
      end
    end

    context 'when the candidate is opted in but has no location preferences' do
      it 'displays "No location preferences recorded"' do
        application_form = create(:application_form)

        create(:candidate_preference, application_form:)
        create(:application_choice, status: :withdrawn, application_form:)

        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).to include('Find a Candidate location preferences')
        expect(result.css('.govuk-summary-list__value').text).to include('No location preferences recorded')
      end
    end
  end
end
