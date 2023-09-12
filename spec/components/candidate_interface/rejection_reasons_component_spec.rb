require 'rails_helper'

RSpec.describe CandidateInterface::RejectionReasonsComponent, :mid_cycle do
  let(:application_form) { create(:completed_application_form) }

  context 'when application is rejected' do
    let!(:application_choice) do
      create(:application_choice, :rejected, application_form:)
    end

    it 'renders component with correct values (with the Find link)' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
      expect(result.css('.govuk-summary-list__key').text).to include('Course')
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.name_and_code)
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.description)
      expect(result.css('.govuk-summary-list__key').text).to include('Feedback')
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.rejection_reason)
      expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
    end

    it 'adds a status row' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').text).to include('Unsuccessful')
    end
  end

  context 'when there are no rejected application choices with feedback' do
    let(:application_choice) do
      create(:application_choice, :rejected, application_form:, rejection_reason: nil)
    end

    it 'does not render' do
      result = render_inline(described_class.new(application_form:))
      expect(result.to_html).to be_blank
    end
  end

  context 'when there is an offer withdrawn application' do
    let!(:application_choice) do
      create(:application_choice, :offer_withdrawn, application_form:)
    end

    it 'renders component with correct values (with the Find link)' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
      expect(result.css('.govuk-summary-list__key').text).to include('Course')
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.name_and_code)
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.course.description)
      expect(result.css('.govuk-summary-list__key').text).to include('Feedback')
      expect(result.css('.govuk-summary-list__value').to_html).to include(application_choice.offer_withdrawal_reason)
      expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
    end

    it 'adds a status row' do
      result = render_inline(described_class.new(application_form:))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').text).to include('Offer withdrawn')
    end
  end

  context 'when application is offer withdrawn' do
    let(:offer_withdrawal_reason) { 'I am withdrawing the offer because of X, Y and Z' }

    it 'renders withdrawn reason' do
      create(:application_choice, :offer_withdrawn, offer_withdrawal_reason:, application_form:)
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Offer withdrawn')
      expect(result.text).to include(offer_withdrawal_reason)
    end
  end
end
