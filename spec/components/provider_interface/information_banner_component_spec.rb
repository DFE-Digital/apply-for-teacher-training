require 'rails_helper'

RSpec.describe ProviderInterface::InformationBannerComponent do
  subject(:result) { render_inline(ProviderInterface::InformationBannerComponent.new) }

  context 'when the provider information banner feature flag is on' do
    before { FeatureFlag.activate('provider_information_banner') }

    it 'renders the banner header' do
      expect(result.text).to include('The Manage service will be unavailable on Thursday 6th May from 8am to 9am')
    end

    it 'renders the banner body' do
      expect(result.text).to include('This will affect both the web service and the API. You may lose work if you are using Manage when it becomes unavailable.')
    end

    context 'when the hosting environment is sandbox' do
      it 'renders the banner header', sandbox: true do
        expect(result.text).to include('The Manage sandbox will be unavailable on Tuesday 4th May from 6pm to 7pm')
      end

      it 'renders the banner body', sandbox: true do
        expect(result.text).to include('This will affect both the web service and the API. You may lose work if you are using the Manage sandbox when it becomes unavailable.')
      end
    end
  end

  context 'when the provider information banner feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('provider_information_banner')

      expect(result.text).to eq('')
    end
  end
end
