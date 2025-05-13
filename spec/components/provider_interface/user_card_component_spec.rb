require 'rails_helper'

RSpec.describe ProviderInterface::UserCardComponent do
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let!(:render) do
    render_inline(
      described_class.new(
        provider_user:,
        provider:,
      ),
    )
  end

  describe 'heading' do
    it 'renders the user full name as a link' do
      expect(render.css('h2 > a').text).to eq(provider_user.full_name)
    end

    it 'renders the user email address' do
      expect(render.css('h2 > span').text).to eq(" - #{provider_user.email_address}")
    end
  end

  context 'when the user has no extra permissions' do
    it 'does not render any permissions' do
      expect(page).to have_no_content(t('provider_interface.user_card_component.permissions_list_preamble'))
      expect(page).to have_no_css('ul')
    end
  end

  context 'when the user has extra permissions' do
    let(:provider_user) do
      provider_traits = ProviderPermissions::VALID_PERMISSIONS.map { |permission| :"with_#{permission}" }
      create(:provider_user, :with_provider, *provider_traits.shuffle)
    end

    it 'renders a list of the user’s permissions' do
      expect(render.css('p.govuk-hint').text.squish).to eq(t('provider_interface.user_card_component.permissions_list_preamble'))
      expect(render.css('li').map(&:text).map(&:squish)).to eq([
        'manage users',
        'manage organisation permissions',
        'manage interviews',
        'send offers, invitations and rejections',
        'view criminal convictions and professional misconduct',
        'view sex, disability and ethnicity information',
      ])
    end
  end
end
