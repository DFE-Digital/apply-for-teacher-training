require 'rails_helper'

RSpec.describe ProviderInterface::SummerRecruitmentBanner do
  before { FeatureFlag.activate('summer_recruitment_banner') }

  subject(:result) { render_inline(described_class.new) }

  context 'when the provider information banner feature flag is on' do
    it 'renders the banner title' do
      expect(result.text).to include('Important')
    end

    it 'renders the banner header' do
      expect(result.text).to include('The deadline for candidates to apply for the first time in this recruitment cycle is 6pm on 7 September')
    end

    it 'renders the banner content' do
      expect(result.text).to include('Candidates who apply before the deadline will be able to apply again until 6pm on 21 September.')
    end
  end

  context 'when the provider information banner feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('summer_recruitment_banner')

      expect(result.text).to be_empty
    end
  end
end
