require 'rails_helper'

RSpec.describe SupportInterface::ProviderUsersTableComponent do
  subject(:rendered_component) do
    render_inline(
      SupportInterface::ProviderUsersTableComponent, provider_users: provider_users
    ).text
  end

  context 'when the provider user has all fields present' do
    let(:provider_users) do
      [
        create(:provider_user,
               email_address: 'provider@example.com',
               dfe_sign_in_uid: 'ABCDEF',
               providers: [create(:provider, name: 'The Provider')]),
      ]
    end

    it 'renders all the fields' do
      expect(rendered_component).to include('provider@example.com')
      expect(rendered_component).to include('ABCDEF')
      expect(rendered_component).to include('The Provider')
    end
  end

  context 'when there are no provider users' do
    let(:provider_users) { [] }

    it { is_expected.to be_blank }
  end
end
