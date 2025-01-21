require 'rails_helper'

RSpec.describe CandidateInterface::OneLoginPostReleaseSignInBannerComponent do
  context 'One login is deactivated' do
    before do
      FeatureFlag.deactivate(:one_login_candidate_sign_in)
    end

    it 'does not renders the component' do
      result = render_inline(described_class.new)
      expect(result.content).to be_empty
    end
  end

  context 'One login is activated' do
    before do
      FeatureFlag.activate(:one_login_candidate_sign_in)
    end

    it 'does render the component' do
      result = render_inline(described_class.new)
      expect(result).to have_content 'How you sign in has changed'
      expect(result).to have_content 'Sign in using your GOV.UK One Login. If you do not have one you can create one.'
      expect(result).to have_content 'If you have signed in to Apply for teacher training before, you should use the same email address to create your GOV.UK One Login.'
    end
  end
end
