require 'rails_helper'

RSpec.describe CandidateInterface::OneLoginPreReleaseLoggedInBannerComponent do
  context 'Pre release banner flag is activated, and one login is not' do
    before do
      FeatureFlag.activate(:one_login_pre_release_banners)
      FeatureFlag.deactivate(:one_login_candidate_sign_in)
    end

    it 'renders the component' do
      result = render_inline(described_class.new(flash_empty: true))

      expect(result).to have_content('How you sign in is changing')
      expect(result).to have_content('From 27 January you’ll sign in using GOV.UK One Login. You’ll be able to create a GOV.UK One Login account if you do not already have one.')
      expect(result).to have_content('Use the same email address for GOV.UK One Login you signed up to Apply for teacher training with to keep your application details.')
    end
  end

  context 'Feature flags are correct, but flash is not empty' do
    before do
      FeatureFlag.activate(:one_login_pre_release_banners)
      FeatureFlag.deactivate(:one_login_candidate_sign_in)
    end

    it 'does not render the component' do
      result = render_inline(described_class.new(flash_empty: false))
      expect(result.content).to be_empty
    end
  end

  context 'Pre release banner flag is deactivated' do
    before do
      FeatureFlag.deactivate(:one_login_pre_release_banners)
    end

    it 'does not render the component' do
      result = render_inline(described_class.new(flash_empty: true))
      expect(result.content).to be_empty
    end
  end

  context 'One login for candidates is activated' do
    before do
      FeatureFlag.activate(:one_login_candidate_sign_in)
    end

    it 'does not render the component' do
      result = render_inline(described_class.new(flash_empty: true))
      expect(result.content).to be_empty
    end
  end
end
