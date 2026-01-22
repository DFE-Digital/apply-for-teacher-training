require 'rails_helper'

RSpec.describe ServiceInformationBanner do
  let(:namespace) { :provider }

  before { FeatureFlag.activate('service_information_banner') }

  subject(:result) { render_inline(described_class.new(namespace:)) }

  context 'in the provider namespace' do
    it 'renders the banner' do
      expect(result.text).to include('Candidate login issues')
    end

    context 'when the hosting environment is sandbox' do
      it 'renders the banner header', :sandbox do
        expect(result.text).to include('Candidate login issues')
      end
    end
  end

  context 'in the candidate namespace' do
    let(:namespace) { :candidate }

    it 'renders the banner' do
      expect(result.text).to include('Login issues')
    end

    context 'when the hosting environment is sandbox' do
      it 'renders the banner header', :sandbox do
        expect(result.text).to include('Login issues')
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
