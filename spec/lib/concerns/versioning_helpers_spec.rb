require 'rails_helper'

RSpec.describe VersioningHelpers do
  include described_class

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
      context 'production env' do
        before { allow(HostingEnvironment).to receive(:production?).and_return(true) }

        it 'returns the latest released minor version' do
          expect(minor_version_number('1')).to eq 1
        end
      end

      context 'sandbox env' do
        before do
          allow(HostingEnvironment).to receive(:production?).and_return(false)
          allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)
        end

        it 'returns the default minor version' do
          expect(minor_version_number('1')).to eq 2
        end
      end

      context 'development env' do
        before do
          allow(HostingEnvironment).to receive(:production?).and_return(false)
          allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(false)
        end

        it 'returns the latest minor version' do
          expect(minor_version_number('1')).to eq 3
        end
      end
    end
  end
end
