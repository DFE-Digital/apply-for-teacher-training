require 'rails_helper'

RSpec.describe CandidateInterface::OneLoginPreReleaseSignInBannerComponent do
  context 'Pre release banner flag is activated, and one login is not' do
    before do
      FeatureFlag.activate(:one_login_pre_release_banners)
      FeatureFlag.deactivate(:one_login_candidate_sign_in)
    end

    it 'renders the component' do
      result = render_inline(described_class.new)

      expect(result).to have_content('How you sign in is changing')
      expect(result).to have_content('During the week of 27 January, users will begin signing in using GOV.UK One Login. You’ll be able to create a GOV.UK One Login if you do not already have one.')
    end
  end

  context 'Pre release banner flag is deactivated' do
    before do
      FeatureFlag.deactivate(:one_login_pre_release_banners)
    end

    it 'does not render the component' do
      result = render_inline(described_class.new)
      expect(result.content).to be_empty
    end
  end

  context 'One login for candidates is activated' do
    before do
      FeatureFlag.activate(:one_login_candidate_sign_in)
    end

    it 'does not render the component' do
      result = render_inline(described_class.new)
      expect(result.content).to be_empty
    end
  end
end
