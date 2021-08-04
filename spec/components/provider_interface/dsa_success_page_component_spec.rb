require 'rails_helper'

RSpec.describe ProviderInterface::DsaSuccessPageComponent do
  let(:provider_user) { create(:provider_user) }
  let(:render) { render_inline(described_class.new(provider_user: provider_user, provider_permission_setup_pending: permissions_require_setup)) }

  context 'when there are permissions to set up' do
    let(:permissions_require_setup) { true }

    it 'shows a continue button' do
      expect(render.css('a').text).to eq('Continue')
    end

    it 'renders the correct text' do
      expect(render.css('p').first.text.squish).to eq('Either you or your partner organisations must set up organisation permissions before you can manage teacher training applications.')
    end
  end

  context 'when permissions have been set up' do
    let(:permissions_require_setup) { false }

    before { allow(ProviderInterface::SetupCompleteNextStepsComponent).to receive(:new).with(provider_user: provider_user).and_call_original }

    it 'renders the next steps component' do
      render
      expect(ProviderInterface::SetupCompleteNextStepsComponent).to have_received(:new)
    end
  end
end
