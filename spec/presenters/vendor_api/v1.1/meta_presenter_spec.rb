require 'rails_helper'

RSpec.describe 'MetaPresenter' do
  subject(:meta_json) { JSON.parse(meta_presenter.new(version, count).as_json) }

  let(:meta_presenter) { VendorAPI::MetaPresenter }
  let(:count) { nil }

  before do
    stub_const('VendorAPI::VERSION', '1.0')
    stub_const(
      'VendorAPI::VERSIONS',
      {
        '1.0' => [VendorAPI::Changes::AddMetaToApplication],
      },
    )
  end

  context 'with major and minor version' do
    let(:version) { '1.0' }

    it 'includes the full API version' do
      expect(meta_json['api_version']).to eq('v1.0')
    end

    it 'does not include the count' do
      expect(meta_json).not_to have_key('total_count')
    end
  end

  context 'with major version' do
    let(:version) { '1' }

    it 'includes the full API version' do
      expect(meta_json['api_version']).to eq('v1.0')
    end

    it 'does not include the count' do
      expect(meta_json).not_to have_key('total_count')
    end
  end

  context 'with a count' do
    let(:count) { 5 }
    let(:version) { '1' }

    it 'includes the `total_count`' do
      expect(meta_json['total_count']).to eq(5)
    end
  end
end
