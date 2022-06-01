require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::AwaitingDecisionCannotRespondComponent do
  describe 'rendered component' do
    it 'renders days left to respond' do
      application_choice = build_stubbed(:application_choice, :awaiting_provider_decision, reject_by_default_at: 3.days.from_now)
      result = render_inline(described_class.new(application_choice: application_choice, provider_can_respond: true))

      expect(result.css('.govuk-body').text).to match(/There are \d+ days to respond/)
      expect(result.css('.govuk-body').text).to match(/This application will be automatically rejected on/)
    end

    it 'omits days left to respond if the application is about to be rejected' do
      application_choice = build_stubbed(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.day.from_now)
      result = render_inline(described_class.new(application_choice: application_choice, provider_can_respond: true))

      expect(result.css('.govuk-body').text).not_to match(/There are \d+ days to respond/)
      expect(result.css('.govuk-body').text).to match(/This application will be automatically rejected at/)
    end
  end
end
