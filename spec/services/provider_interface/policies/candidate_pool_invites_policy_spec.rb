require 'rails_helper'

RSpec.describe ProviderInterface::Policies::CandidatePoolInvitesPolicy do
  let(:providers) { create_list(:provider, 3) }
  let(:provider_user) { create(:provider_user, providers:) }

  describe '#can_invite_candidates?' do
    context 'when make_decision is set to true for some providers' do
      it 'returns true' do
        provider_user.provider_permissions.first.update(make_decisions: true)

        expect(described_class.new(provider_user).can_invite_candidates?).to be true
      end
    end

    context 'when user has multiple providers, none with make_decision set to true' do
      it 'returns false' do
        provider_user.provider_permissions.update_all(make_decisions: false)

        expect(described_class.new(provider_user).can_invite_candidates?).to be false
      end
    end

    context 'when user has multiple providers, all with make_decision set to true' do
      it 'returns true' do
        provider_user.provider_permissions.update_all(make_decisions: true)

        expect(described_class.new(provider_user).can_invite_candidates?).to be true
      end
    end
  end

  describe '#can_edit_invite?' do
    let(:course) { create(:course, :open, provider: providers.first) }
    let(:invite) { create(:pool_invite, course:, invited_by: provider_user, provider: course.provider) }

    context 'invite is for a provider the user has permissions to make decisions for' do
      it 'returns true' do
        provider_user.provider_permissions.where(provider: course.provider).first.update(make_decisions: true)

        expect(described_class.new(provider_user).can_edit_invite?(invite)).to be true
      end
    end

    context 'invite is for a provider the user does NOT have permission to make decisions for' do
      it 'returns false' do
        provider_user.provider_permissions.where(provider: course.provider).first.update(make_decisions: false)

        expect(described_class.new(provider_user).can_edit_invite?(invite)).to be false
      end
    end
  end
end
