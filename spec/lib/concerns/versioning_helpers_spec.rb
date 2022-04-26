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
      it 'returns the latest released minor version' do
        expect(minor_version_number('1')).to eq 1
      end
    end
  end
end
