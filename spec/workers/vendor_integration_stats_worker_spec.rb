require 'rails_helper'

RSpec.describe VendorIntegrationStatsWorker do
  describe '#perform' do
    let(:worker) { described_class.new }

    before do
      double = instance_double(VendorIntegrationStatsWorker::SlackReport)
      allow(double).to receive(:generate).and_return('test')
      allow(VendorIntegrationStatsWorker::SlackReport).to receive(:new).and_return(double)
    end

    it 'determines the environment variable for webhook url from the vendor name' do
      slack_request = stub_request(:post, 'https://example.com/webhook')
        .to_return(status: 200, headers: {})

      ClimateControl.modify TRIBAL_INTEGRATION_STATS_SLACK_URL: 'https://example.com/webhook' do
        worker.perform('tribal')
      end

      expect(slack_request).to have_been_made
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
    let(:slack_report) { VendorIntegrationStatsWorker::SlackReport.new('tribal') }
    let(:providers) { create_list(:provider, 2) }

    before do
      double = instance_double(SupportInterface::VendorAPIMonitor)
      allow(double).to receive(:never_connected).and_return(providers)
      allow(double).to receive(:no_sync_in_24h).and_return(providers)
      allow(double).to receive(:no_decisions_in_7d).and_return(providers)
      allow(double).to receive(:providers_with_errors).and_return(providers)

      allow(SupportInterface::VendorAPIMonitor).to receive(:new).with(vendor: vendor).and_return(double)
    end

    it 'initialises a VendorAPIMonitor for the relevant vendor' do
      slack_report.generate
      expect(SupportInterface::VendorAPIMonitor).to have_received(:new).with(vendor: vendor)
    end

    it 'generates a text-based report for sending to Slack' do
      report = slack_report.generate
      expect(report).to include('```')
      expect(report).to include('Tribal')
      expect(report).to include('Never connected via API')
      expect(report).to include('No API sync in the last 24h')
      expect(report).to include('No API decisions in the last 7 days')
      expect(report).to include('Providers with API errors')
    end
  end
end
