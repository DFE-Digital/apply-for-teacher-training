require 'rails_helper'

RSpec.describe VendorAPI::Base do
  include APITest
  before do
    stub_const('VendorAPI::VERSIONS', { '1.0' => [APITest::FirstTestVersionChange],
                                        '1.1' => [APITest::SecondTestVersionChange],
                                        '1.2' => [APITest::ThirdTestVersionChange] })
  end

  subject(:presenter) { APITest::PresenterClass.new(version) }

  context 'class with no versioned modules' do
    let(:version) { '1.0' }

    it 'sets the active version' do
      expect(presenter.active_version).to eq(version)
    end
  end

  context 'class with versioned modules' do
    context 'when the version is 1.2' do
      let(:version) { '1.2' }

      it 'includes all the specified modules' do
        expect(presenter.singleton_class.included_modules.map(&:to_s)).to include('APITest::TestModule')
      end

      it 'merges attributes in the order they were specified' do
        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'three keys',
        })
      end
    end

    context 'when the version is 1.1' do
      let(:version) { '1.1' }

      it 'merges attributes for versions up to the active one' do
        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'two keys',
        })
      end
    end
  end
end
