require 'rails_helper'

RSpec.describe ProviderInterface::SummerRecruitmentBanner do
  before { FeatureFlag.activate('summer_recruitment_banner') }

  subject(:result) { render_inline(described_class.new) }

  context 'when the provider information banner feature flag is on' do
    it 'renders the banner title' do
      expect(result.text).to include('Important')
    end

    it 'renders the banner header' do
      expect(result.text).to include('Applications will be automatically rejected if you do not make a decision within 20 working days')
    end

    it 'renders the banner content' do
      expect(result.text).to include('This reduced time to make a decision will last until the recruitment cycle ends on 4 October.')
    end
  end

  context 'when the provider information banner feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('summer_recruitment_banner')

      expect(result.text).to be_empty
    end
  end
end
