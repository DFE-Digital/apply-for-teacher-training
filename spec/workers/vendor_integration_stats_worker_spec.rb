require 'rails_helper'

RSpec.describe VendorIntegrationStatsWorker do
  describe '#perform' do
    let(:worker) { described_class.new }
    let(:messages) { ['test'] }

    before do
      double = instance_double(VendorIntegrationStatsWorker::SlackReport)
      allow(double).to receive(:generate).and_return(messages)
      allow(VendorIntegrationStatsWorker::SlackReport).to receive(:new).and_return(double)
    end

    context 'posting the request successfully' do
      it 'determines the environment variable for webhook url from the vendor name' do
        slack_request = stub_request(:post, 'https://example.com/webhook')
          .to_return(status: 200, headers: {})

        ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: 'https://example.com/webhook' do
          worker.perform('tribal')
        end

        expect(slack_request).to have_been_made
      end

      context 'when the request is too long' do
        let(:messages) { ['test' * 300, 'this' * 400, 'string' * 500] }

        it 'posts each section separately' do
          slack_request = stub_request(:post, 'https://example.com/webhook')
            .to_return(status: 200, headers: {})

          ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: 'https://example.com/webhook' do
            worker.perform('tribal')
          end

          expect(slack_request).to have_been_made.times(messages.count)
        end
      end
    end

    it 'does not send a Slack notification if the environment variable is empty' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: '' do
        worker.perform('tribal')
      end

      expect(slack_request).not_to have_been_made
    end

    it 'does not send a Slack notification if the environment variable is not set' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: nil do
        worker.perform('tribal')
      end

      expect(slack_request).not_to have_been_made
    end

    it 'raises an error if Slack responds with one' do
      stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 400, headers: {})

      ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: 'https://example.com/webhook' do
        expect { worker.perform('tribal') }.to raise_error(VendorIntegrationStatsWorker::SlackMessageError)
      end
    end
  end

  describe 'SlackReport' do
    let!(:vendor) { create(:vendor, name: 'tribal') }
    let(:slack_report) { VendorIntegrationStatsWorker::SlackReport.new(vendor.name) }

    context 'report structure' do
      let(:providers) { create_list(:provider, 2) }

      before do
        double = instance_double(SupportInterface::VendorAPIMonitor)
        allow(double).to receive_messages(never_connected: providers, no_sync_in_7d: providers, no_decisions_in_7d: providers, providers_with_errors: providers)

        allow(SupportInterface::VendorAPIMonitor).to receive(:new).with(vendor:).and_return(double)
      end

      it 'initialises a VendorAPIMonitor for the relevant vendor' do
        slack_report.generate

        expect(SupportInterface::VendorAPIMonitor).to have_received(:new).with(vendor:)
      end

      it 'generates a text-based report for sending to Slack' do
        report = slack_report.generate.join('\n')
        expect(report).to include('```')
        expect(report).to include('Tribal')
        expect(report).to include('Never connected via API')
        expect(report).to include('No API sync in the last 7 days')
        expect(report).to include('No API decisions in the last 7 days')
        expect(report).to include('Providers with API errors')
      end
    end

    context 'rendering information' do
      let!(:provider) { create(:provider, name: 'Hogwards', vendor:) }
      let!(:other_provider) { create(:provider, name: 'Durmstrang', vendor:) }
      let!(:no_error_provider) { create(:provider, name: 'Uagadou', vendor:) }

      before do
        create_list(:vendor_api_request, 5, :with_validation_error, provider:)
        create_list(:vendor_api_request, 5, provider:)
        create_list(:vendor_api_request, 2, :with_validation_error, provider: other_provider)
        create_list(:vendor_api_request, 9, provider: other_provider)
        create_list(:vendor_api_request, 3, provider: no_error_provider)
      end

      it 'renders the error rate correctly' do
        report = slack_report.generate.join("\n")

        expect(report).to include("Hogwards                                          \t                 50.00%\n")
        expect(report).to include("Durmstrang                                        \t                 18.18%\n")
      end
    end
  end
end
