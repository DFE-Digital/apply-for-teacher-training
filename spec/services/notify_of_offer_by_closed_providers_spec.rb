require 'rails_helper'

RSpec.describe NotifyOfOfferByClosedProviders do
  let(:helpers) { Rails.application.routes.url_helpers }

  before do
    allow(SlackNotificationWorker).to receive(:perform_async)
  end

  describe '#call' do
    let(:provider) { create(:provider, code: 'X100') }
    let(:accredited_provider) { create(:provider, code: 'A67') }
    let(:application_choice) { create(:application_choice, course: create(:course, provider: provider, accredited_provider: accredited_provider)) }
    let(:application_form_id) { application_choice.application_form.id }

    context 'when the provider is not closed' do
      it 'does not notify the slack channel' do
        stub_const('NotifyOfOfferByClosedProviders::CLOSED_PROVIDERS', ['B28'])
        expect(SlackNotificationWorker).not_to have_received(:perform_async)
      end
    end

    context 'when the provider is not closed but the accredited provider is' do
      before do
        stub_const('NotifyOfOfferByClosedProviders::CLOSED_PROVIDERS', ['A67'])

        described_class.new(
          application_choice:,
        ).call
      end

      it 'mentions the accredited provider name' do
        message = ":bangbang: #{accredited_provider.name} has made an offer to a candidate – this provider is currently closed."
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything, '#bat_provider_changes')
      end

      it 'links the notification to the relevant support_interface application_form' do
        url = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, url, '#bat_provider_changes')
      end
    end

    context 'when the provider is closed' do
      before do
        stub_const('NotifyOfOfferByClosedProviders::CLOSED_PROVIDERS', ['X100'])

        described_class.new(
          application_choice:,
        ).call
      end

      it 'mentions the provider name' do
        message = ":bangbang: #{provider.name} has made an offer to a candidate – this provider is currently closed."
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything, '#bat_provider_changes')
      end

      it 'links the notification to the relevant support_interface application_form' do
        url = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, url, '#bat_provider_changes')
      end
    end
  end
end
