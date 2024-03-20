require 'rails_helper'

RSpec.describe Modules::AWSIpRanges do
  describe '.cloudfront_ips' do
    before do
      aws_ip_ranges = Rails.root.join('spec/examples/aws_ip_ranges.json').read
      stub_request(:get, described_class::PATH).to_return(body: aws_ip_ranges, status: 200)
    end

    it 'returns the CLOUDFRONT ip in the GLOBAL or eu-west-2 area' do
      expected_result = %w[13.32.0.0/15 13.35.0.0/16 52.56.127.0/25]

      expect(described_class.cloudfront_ips).to eq(expected_result)
    end

    context 'when there was any connectivity issue' do
      before do
        stub_request(:get, described_class::PATH).to_timeout
      end

      it 'returns an empty array' do
        expect(described_class.cloudfront_ips).to eq([])
      end

      it 'logs a warning to sentry' do
        allow(Sentry).to receive(:capture_exception)
        described_class.cloudfront_ips
        expect(Sentry).to have_received(:capture_exception)
      end
    end

    context 'when another type of Net::HTTP error is raised' do
      before do
        stub_request(:get, described_class::PATH).to_raise(Net::ProtocolError)
      end

      it 'returns an empty array' do
        expect(described_class.cloudfront_ips).to eq([])
      end

      it 'logs a warning to sentry' do
        allow(Sentry).to receive(:capture_exception)
        described_class.cloudfront_ips
        expect(Sentry).to have_received(:capture_exception)
      end
    end

    context 'when the response was 403 and not JSON' do
      before do
        aws_ip_ranges = Rails.root.join('spec/examples/bad_aws_ip_ranges.xml').read
        stub_request(:get, described_class::PATH).to_return(body: aws_ip_ranges, status: 403)
      end

      it 'returns an empty array' do
        expect(described_class.cloudfront_ips).to eq([])
      end

      it 'logs a warning' do
        allow(Sentry).to receive(:capture_exception)
        described_class.cloudfront_ips
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end
end
