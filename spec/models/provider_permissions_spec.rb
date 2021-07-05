require 'rails_helper'

RSpec.describe ProviderPermissions do
  context 'scopes' do
    describe 'set_up_interviews' do
      it 'returns all permissions where `set_up_interviews` is set' do
        create_list(:provider_permissions, 3, set_up_interviews: false)
        interview_permissions = create_list(:provider_permissions, 2, set_up_interviews: true)

        expect(described_class.set_up_interviews).to eq(interview_permissions)
      end
    end
  end

  describe '.possible_permissions' do
    let(:current_provider_user) { create(:provider_user, providers: providers) }
    let(:provider_user) { create(:provider_user, providers: providers << non_visible_provider) }
    let(:non_visible_provider) { create(:provider, name: 'ZZZ') }
    let(:providers) do
      [
        create(:provider, name: 'ABC'),
        create(:provider, name: 'AAA'),
        create(:provider, name: 'ABB'),
      ]
    end

    before { current_provider_user.provider_permissions.update_all(manage_users: true) }

    it 'returns an ordered collection of provider permissions the current user can assign to other users' do
      expected_provider_names = described_class.possible_permissions(
        current_provider_user: current_provider_user,
        provider_user: provider_user,
      ).map { |p| p.provider.name }

      expect(expected_provider_names).to eq(%w[AAA ABB ABC])
    end
  end

  describe '#view_applications_only?' do
    let(:current_provider_user) { create(:provider_user, providers: [create(:provider)]) }

    it 'returns true when there are not permissions' do
      expect(current_provider_user.provider_permissions.first.view_applications_only?).to eq(true)
    end

    it 'returns false if there is at least one permission' do
      current_provider_user.provider_permissions.update(make_decisions: true)

      expect(current_provider_user.provider_permissions.first.view_applications_only?).to eq(false)
    end
  end
end
