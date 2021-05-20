require 'rails_helper'

RSpec.describe AWSIpRanges do
  describe '.cloudfront_ips' do
    before do
      aws_ip_ranges = File.read(
        Rails.root.join('spec/examples/aws_ip_ranges.json'),
      )
      stub_request(:get, AWSIpRanges::PATH).to_return(body: aws_ip_ranges, status: 200)
    end

    it 'returns the CLOUDFRONT ip in the GLOBAL or eu-west-2 area' do
      expected_result = %w[13.32.0.0/15 13.35.0.0/16 52.56.127.0/25]

      expect(AWSIpRanges.cloudfront_ips).to eq(expected_result)
    end

    context 'when there was any connectivity issue' do
      before do
        stub_request(:get, AWSIpRanges::PATH).to_timeout
      end

      it 'returns an empty array' do
        expect(AWSIpRanges.cloudfront_ips).to eq([])
      end

      it 'logs a warning to sentry' do
        allow(Raven).to receive(:capture_exception)
        AWSIpRanges.cloudfront_ips
        expect(Raven).to have_received(:capture_exception)
      end
    end

    context 'when another type of Net::HTTP error is raised' do
      before do
        stub_request(:get, AWSIpRanges::PATH).to_raise(Net::ProtocolError)
      end

      it 'returns an empty array' do
        expect(AWSIpRanges.cloudfront_ips).to eq([])
      end

      it 'logs a warning to sentry' do
        allow(Raven).to receive(:capture_exception)
        AWSIpRanges.cloudfront_ips
        expect(Raven).to have_received(:capture_exception)
      end
    end

    context 'when the response was 403 and not JSON' do
      before do
        aws_ip_ranges = File.read(
          Rails.root.join('spec/examples/bad_aws_ip_ranges.xml'),
        )
        stub_request(:get, AWSIpRanges::PATH).to_return(body: aws_ip_ranges, status: 403)
      end

      it 'returns an empty array' do
        expect(AWSIpRanges.cloudfront_ips).to eq([])
      end

      it 'logs a warning' do
        allow(Raven).to receive(:capture_exception)
        AWSIpRanges.cloudfront_ips
        expect(Raven).to have_received(:capture_exception)
      end
    end
  end
end
