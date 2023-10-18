require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::AwaitingDecisionCannotRespondComponent do
  describe 'rendered component' do
    it 'renders days left to respond' do
      application_choice = build_stubbed(:application_choice, :awaiting_provider_decision)
      result = render_inline(described_class.new(application_choice:, provider_can_respond: false))

      expect(result.css('h2').text.strip).not_to eq('Make a decision')
      expect(result.css('.govuk-body').text.strip).to eq(
        'This application was received today. You should try and respond to the candidate within 30 days.',
      )
      expect(result.css('.govuk-button').text.strip).not_to eq('Make decision')
    end
  end
end
