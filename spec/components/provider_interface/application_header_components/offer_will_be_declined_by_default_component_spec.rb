require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::OfferWillBeDeclinedByDefaultComponent do
  describe 'rendered component' do
    it 'renders offer content' do
      application_choice = build_stubbed(:application_choice, :offered)
      result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

      expect(result.css('h2').text.strip).to eq('Waiting for candidate’s response')
      expect(result.css('.govuk-body').text).to match('You made this offer today. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.')
    end
  end

  describe '#offer_text' do
    context 'when the offer was made today' do
      it 'renders the correct text' do
        application_choice = build_stubbed(:application_choice, :offered)

        expected_text = 'You made this offer today. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.'
        expect(described_class.new(application_choice:).offer_text).to eq(expected_text)
      end
    end

    context 'when the offer was made before today' do
      it 'renders the correct text' do
        application_choice = build_stubbed(:application_choice, :offered, offered_at: 3.days.ago)

        expected_text = 'You made this offer 3 days ago. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond.'
        expect(described_class.new(application_choice:).offer_text).to eq(expected_text)
      end
    end
  end
end
