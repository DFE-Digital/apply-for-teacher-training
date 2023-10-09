require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::OfferWillBeDeclinedByDefaultComponent, :continuous_applications do
  describe 'rendered component' do
    it 'renders offer content' do
      application_choice = build_stubbed(:application_choice, :offered)
      result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

      expect(result.css('h2').text.strip).to eq('Waiting for candidate’s response')
      expect(result.css('.govuk-body').text).to match('You made this offer today. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.')
    end
  end

  describe 'rendered component', continuous_applications: false do
    it 'renders offer will be declined content' do
      application_choice = build_stubbed(:application_choice, :offered)
      result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

      expect(result.css('h2').text.strip).to eq('Waiting for candidate’s response')
      expect(result.css('.govuk-body').text).to match(/Your offer will be automatically declined in \d+ days .*? if the candidate does not respond/)
    end
  end

  context 'when not continuous applications', continuous_applications: false do
    describe '#decline_by_default_text' do
      it 'returns nil if the application is not in the offer state' do
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision')

        expect(described_class.new(application_choice:).decline_by_default_text).to be_nil
      end

      describe 'returns the correct text when' do
        it 'the dbd is today' do
          application_choice = build_stubbed(
            :application_choice,
            status: 'offer',
            decline_by_default_at: Time.zone.now.end_of_day,
          )

          expected_text = "at the end of today (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
          expect(described_class.new(application_choice:).decline_by_default_text).to eq(expected_text)
        end

        it 'the dbd is tomorrow' do
          application_choice = build_stubbed(
            :application_choice,
            status: 'offer',
            decline_by_default_at: 1.day.from_now.end_of_day,
          )

          expected_text = "at the end of tomorrow (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
          expect(described_class.new(application_choice:).decline_by_default_text).to eq(expected_text)
        end

        it 'the dbd is after tomorrow' do
          application_choice = build_stubbed(
            :application_choice,
            status: 'offer',
            decline_by_default_at: 3.days.from_now.end_of_day,
          )

          expected_text = "in 3 days (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
          expect(described_class.new(application_choice:).decline_by_default_text).to eq(expected_text)
        end
      end
    end
  end

  describe '#continuous_applications_offer_text' do
    context 'when the offer was made today' do
      it 'renders the correct text' do
        application_choice = build_stubbed(:application_choice, :continuous_applications, :offered)

        expected_text = 'You made this offer today. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.'
        expect(described_class.new(application_choice:).continuous_applications_offer_text).to eq(expected_text)
      end
    end

    context 'when the offer was made before today' do
      it 'renders the correct text' do
        application_choice = build_stubbed(:application_choice, :continuous_applications, :offered, offered_at: 3.days.ago)

        expected_text = 'You made this offer 3 days ago. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.'
        expect(described_class.new(application_choice:).continuous_applications_offer_text).to eq(expected_text)
      end
    end
  end
end
