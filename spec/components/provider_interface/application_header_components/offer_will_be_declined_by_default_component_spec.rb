require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::OfferWillBeDeclinedByDefaultComponent do
  describe 'rendered component' do
    it 'renders offer will be declined content' do
      application_choice = build_stubbed(:application_choice, :with_offer)
      result = render_inline(described_class.new(application_choice: application_choice, provider_can_respond: true))

      expect(result.css('h2').text.strip).to eq('Waiting for candidate’s response')
      expect(result.css('.govuk-body').text).to match(/Your offer will be automatically declined in \d+ days .*? if the candidate does not respond/)
    end
  end

  describe '#decline_by_default_text' do
    it 'returns nil if the application is not in the offer state' do
      application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision')

      expect(described_class.new(application_choice: application_choice).decline_by_default_text).to be_nil
    end

    describe 'returns the correct text when' do
      it 'the dbd is today' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: Time.zone.now.end_of_day,
        )

        expected_text = "at the end of today (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end

      it 'the dbd is tomorrow' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: 1.day.from_now.end_of_day,
        )

        expected_text = "at the end of tomorrow (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end

      it 'the dbd is after tomorrow' do
        application_choice = build_stubbed(
          :application_choice,
          status: 'offer',
          decline_by_default_at: 3.days.from_now.end_of_day,
        )

        expected_text = "in 3 days (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
        expect(described_class.new(application_choice: application_choice).decline_by_default_text).to eq(expected_text)
      end
    end
  end
end
