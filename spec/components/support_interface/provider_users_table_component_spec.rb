require 'rails_helper'

RSpec.describe SupportInterface::ProviderUsersTableComponent do
  subject(:rendered_component) do
    render_inline(
      SupportInterface::ProviderUsersTableComponent.new(provider_users: provider_users),
    ).text
  end

  context 'when the provider user has all fields present' do
    let(:provider_users) do
      [
        create(:provider_user,
               email_address: 'provider@example.com',
               last_signed_in_at: Time.zone.local(2019, 12, 1, 10, 45, 0),
               providers: [create(:provider, name: 'The Provider')]),
      ]
    end

    it 'renders all the fields' do
      expect(rendered_component).to include('provider@example.com')
      expect(rendered_component).to include('The Provider')
    end
  end

  context 'when there are no provider users' do
    let(:provider_users) { [] }

    it { is_expected.to be_blank }
  end

  describe 'permissions link' do
    before do
      FeatureFlag.activate(:new_provider_user_flow)
    end

    context 'when the provider user has permissions' do
      let(:provider_users) do
        [
          create(:provider_user, :with_provider),
        ]
      end

      it 'renders a link to edit permissions' do
        expect(rendered_component).to include('Update permissions')
      end
    end

    context 'when the provider user lacks permissions' do
      let(:provider_users) do
        [
          create(:provider_user),
        ]
      end

      it 'renders no link to edit permissions' do
        expect(rendered_component).not_to include('Update permissions')
      end
    end
  end
end
