require 'rails_helper'

RSpec.describe VendorAPI::Base do
  include APITest

  let(:version) { '1.0' }

  context 'class with the minimum setup' do
    subject(:presenter) { PresenterClass.new(version) }

    let(:presenter_class) { Class.new(described_class) }

    before do
      stub_const('PresenterClass', presenter_class)
    end

    it 'sets the active version' do
      expect(presenter.active_version).to eq(version)
    end
  end

  context 'class with versioned modules' do
    subject(:presenter) { APITest::PresenterClass.new(version) }

    context 'when the version is 1.1' do
      let(:version) { '1.1' }

      it 'includes all the specified modules' do
        expect(presenter.class.included_modules.map(&:to_s)).to include('APITest::TestModule')
      end

      it 'merges attributes in the order they were specified' do
        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'three keys',
        })
      end
    end

    context 'when the version is 1.0', wip: true do
      let(:version) { '1.0' }

      it 'merges attributes for versions up to the active one' do
        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'two keys',
        })
      end
    end
  end
end
