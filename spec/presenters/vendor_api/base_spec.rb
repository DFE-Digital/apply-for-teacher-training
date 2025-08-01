require 'rails_helper'

RSpec.describe VendorAPI::Base do
  include APITest

  before do
    stub_const('VendorAPI::VERSION', '1.2')
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

  context 'accessing a presenter that is introduced in a later version' do
    before do
      stub_const('VendorAPI::VERSIONS', { '1.1' => [APITest::FirstTestVersionChange],
                                          '1.2' => [APITest::SecondTestVersionChange] })
    end

    subject(:presenter) { APITest::PresenterClass.new(version) }

    let(:version) { '1.0' }

    it 'throws an exception' do
      expect { presenter }.to raise_error(PresenterNotVersioned)
    end
  end

  context 'accessing a presenter that is introduced in a prereleased version' do
    before do
      stub_const('VendorAPI::VERSIONS', { '1.0' => [APITest::FirstTestVersionChange],
                                          '1.1' => [APITest::SecondTestVersionChange],
                                          '1.2pre' => [APITest::ThirdTestVersionChange] })
    end

    subject(:presenter) { APITest::PresenterClass.new(version) }

    let(:version) { '1.2' }

    context 'when the environment is production' do
      it 'throws an exception' do
        allow(HostingEnvironment).to receive(:production?).and_return(true)

        expect { presenter }.to raise_error(ActiveVersionNotAvailableInEnvironment)
      end
    end

    context 'when the environment is sandbox' do
      it 'merges attributes for versions matching the specified version, including prerelease' do
        allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'three keys',
        })
      end
    end

    context 'when the environment is not production or sandbox' do
      it 'merges attributes for all specified versions' do
        allow(HostingEnvironment).to receive_messages(production?: false, sandbox_mode?: false)

        expect(presenter.schema).to eq({
          one: 'two keys',
          two: 'three keys',
        })
      end
    end

    context 'when the environment is sandbox and the version constant is prior to prerelease' do
      let(:version) { '1.2' }

      before do
        stub_const('VendorAPI::VERSION', '1.1')
      end

      it 'raises an exception' do
        allow(HostingEnvironment).to receive(:sandbox_mode?).and_return(true)

        expect { presenter }.to raise_error(ActiveVersionNotAvailableInEnvironment)
      end
    end
  end
end
