require 'rails_helper'

RSpec.describe VersioningHelpers do
  include described_class

  describe '#released_version' do
    context 'production' do
      before { allow(HostingEnvironment).to receive(:production?).and_return true }

      it 'returns the production version' do
        expect(released_version).to eq '1.6'
      end
    end

    context 'sandbox' do
      before { allow(HostingEnvironment).to receive(:sandbox_mode?).and_return true }

      it 'returns the pre-release' do
        expect(released_version).to eq '1.7'
      end
    end

    context 'development environments' do
      it 'returns the pre-release' do
        expect(released_version).to eq '1.7'
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
  end
end
