require 'rails_helper'

RSpec.describe VersioningHelpers do
  include described_class

  describe '#released_version' do
    context 'production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return true }

      it 'returns the production version' do
        expect(released_version).to eq '2.0'
      end
    end

    context 'sandbox' do
      before { allow(HostingEnvironment).to receive(:sandbox_mode?).and_return true }

      it 'returns the release' do
        expect(released_version).to eq '2.0'
      end
    end

    context 'development environments' do
      it 'returns the release' do
        expect(released_version).to eq '2.0'
      end
    end
  end

  describe '#minor_version_number' do
    before do
      stub_const('VendorAPI::VERSION', '1.2')
      stub_const(
        'VendorAPI::VERSIONS',
        {
          '1.0' => [],
          '1.1' => [],
          '1.2pre' => [],
          '1.3pre' => [],
        },
      )
    end

    context 'no minor version specified' do
      it 'returns the latest released minor version' do
        expect(minor_version_number('1')).to eq 1
      end
    end

    context 'with two major versions released' do
      before do
        stub_const('VendorAPI::VERSION', '2.0')
        stub_const(
          'VendorAPI::VERSIONS',
          {
            '1.0' => [],
            '1.1' => [],
            '1.2' => [],
            '1.3pre' => [],
            '2.0' => [],
            '2.1pre' => [],
          },
        )
      end

      it 'returns the latest released minor version of version 1' do
        expect(minor_version_number('1')).to eq 2
      end

      it 'returns the latest released minor version of version 2' do
        expect(minor_version_number('2')).to eq 0
      end
    end

    context 'with a major version that is a string prefix of another' do
      before do
        stub_const('VendorAPI::VERSION', '10.5')
        stub_const(
          'VendorAPI::VERSIONS',
          {
            '1.0' => [],
            '1.1' => [],
            '10.0' => [],
            '10.5' => [],
          },
        )
      end

      it 'matches the major version exactly, not by string prefix' do
        expect(minor_version_number('1')).to eq 1
      end
    end

    context 'when no production version exists for the major version' do
      it 'raises an error rather than returning nil' do
        expect { minor_version_number('3') }.to raise_error(ArgumentError, /major version 3/)
      end
    end
  end
end
