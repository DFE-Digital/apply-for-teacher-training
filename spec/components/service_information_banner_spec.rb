require 'rails_helper'

RSpec.describe ServiceInformationBanner do
  let(:namespace) { :provider }

  before { FeatureFlag.activate('service_information_banner') }

  subject(:result) { render_inline(ServiceInformationBanner.new(namespace: namespace)) }

  context 'in the provider namespace' do
    it 'renders the banner' do
      expect(result.text).to include('Manage service')
    end

    context 'when the hosting environment is sandbox' do
      it 'renders the banner header', sandbox: true do
        expect(result.text).to include('Manage sandbox')
      end
    end
  end

  context 'in the candidate namespace' do
    let(:namespace) { :candidate }

    it 'renders the banner' do
      expect(result.text).to include('Apply service')
    end

    context 'when the hosting environment is sandbox' do
      it 'renders the banner header', sandbox: true do
        expect(result.text).to include('Apply sandbox')
      end
    end
  end

  context 'when the provider information banner feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('service_information_banner')

      expect(result.text).to be_empty
    end
  end
end
